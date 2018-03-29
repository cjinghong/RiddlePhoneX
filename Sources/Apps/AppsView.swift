import Foundation
import UIKit

public protocol AppsViewDelegate: class {
    func shouldShowAccessoryButton(withTitle title: String, position: Position, action: @escaping (() -> Void))
    func shouldHideAccessoryButton()

    func shouldCongratulate()
}

/// Screen containing scrollable apps.
public class AppsView: UIView {

    private var riddle: Riddle?

    // MARK: - evanEvanWhereAreYou
    private var evanFound: Bool = false {
        didSet {
            // Remove random index path
            randomIndexPath = nil
        }
    }
    private var randomIndexPath: IndexPath?
    private let maxWrongGuessCount: Int = 3
    private var wrongGuesses: Int = 0

    // MARK: - Stop hiding
    private var waitingForEvan: Bool = false
    private var cellExpansionScale: CGFloat = 1.5





    /// If the user is organizing apps 
    private(set) var isOrganisingApps: Bool = false {
        didSet {
            if isOrganisingApps {
                delegate?.shouldShowAccessoryButton(withTitle: "Done", position: .topRight, action: { [weak self] in
                    self?.stopOrganisingApps()
                })
            }
        }
    }
    private(set) var apps: [BaseApp] = []
    private(set) var bottomApps: [BaseApp] = [
        BaseApp(contentView: UIView(), name: "Phone", icon: UIImage(named: "AppIcon/phone")),
        BaseApp(contentView: UIView(), name: "Calculator", icon: UIImage(named: "AppIcon/calculator")),
        BaseApp(contentView: UIView(), name: "Safari", icon: UIImage(named: "AppIcon/safari"))
    ]

    public weak var delegate: AppsViewDelegate?

//    private let APPSCELLSPACING: CGFloat = 23

    private var bottomAppBarCollectionView: UICollectionView!
    private var appsCollectionView: UICollectionView!

    private var pageControl: UIPageControl!
    private var bottomAppBar: UIView!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public init(frame: CGRect, delegate: AppsViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        setup()
    }

    // MARK: - Public
    /// Sets the apps immediately, replaces existing apps
    public func setApps(_ apps: [BaseApp]) {
        self.apps = apps
        let range = Range(uncheckedBounds: (0, appsCollectionView.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        appsCollectionView.reloadSections(indexSet)
    }

    /// Installs a new app
    public func install(_ app: BaseApp) {
        self.apps.append(app)
        let range = Range(uncheckedBounds: (0, appsCollectionView.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        appsCollectionView.reloadSections(indexSet)
    }

    /// Uninstalls an app
    public func uninstall(_ app: BaseApp) {
        guard let index = self.apps.index(of: app) else { return }
        apps.remove(at: index)
        let range = Range(uncheckedBounds: (0, appsCollectionView.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        appsCollectionView.reloadSections(indexSet)
    }

    public func uninstallAllApps() {
        apps.removeAll()
        let range = Range(uncheckedBounds: (0, appsCollectionView.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        appsCollectionView.reloadSections(indexSet)
    }

    public func setupForRiddle(_ riddle: Riddle) {
        self.riddle = riddle

        delegate?.shouldShowAccessoryButton(withTitle: "Solve", position: .topLeft, action: {
            guard let indexPath = self.randomIndexPath else { return }
            self.beginAnimatingEvanIsFound(indexPathOfEvansCell: indexPath, inCollectionView: self.appsCollectionView, nil)
        })

        switch riddle {
        case .evanEvanWhereAreYou, .stopHiding:
            var apps = [BaseApp]()
            for i in 1..<19 {
                apps.append(BaseApp(contentView: UIView(), name: "\(i)", icon: nil))
            }
            setApps(apps)

            // Generate random number
            let randInt = Int.random(min: 0, max: apps.count)

            // Populate random index path
            self.randomIndexPath = IndexPath(item: randInt, section: 0)
        }
    }

    // MARK: - Setup code
    private func createBottomAppBar() {
        // Bottom app bar
        let marginSides: CGFloat = 10
        let marginBottom: CGFloat = 10
        let height: CGFloat = frame.height * 0.1
        bottomAppBar = UIView(frame: CGRect(x: marginSides,
                                            y: frame.height - marginBottom - height,
                                            width: frame.width - marginSides - marginSides,
                                            height: height))
        bottomAppBar.clipsToBounds = true
        bottomAppBar.layer.cornerRadius = 20
        let veView = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: bottomAppBar.frame.width, height: bottomAppBar.frame.height))
        veView.effect = UIBlurEffect(style: .light)
        bottomAppBar.addSubview(veView)

        // Create bottom apps collection view (Fixed apps)
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: AppCell.cellWidth, height: AppCell.cellWidth)
        flowlayout.minimumLineSpacing = 10

        bottomAppBarCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: bottomAppBar.bounds.width, height: bottomAppBar.bounds.height), collectionViewLayout: flowlayout)
        bottomAppBarCollectionView.backgroundColor = nil

        bottomAppBarCollectionView.register(AppCell.self, forCellWithReuseIdentifier: "AppCell")
        bottomAppBarCollectionView.dataSource = self
        bottomAppBarCollectionView.delegate = self
        bottomAppBar.addSubview(bottomAppBarCollectionView)

        self.addSubview(bottomAppBar)
    }

    private func createPageControl() {
        let height: CGFloat = 20
        pageControl = UIPageControl(frame: CGRect(x: 0,
                                                  y: bottomAppBar.frame.origin.y - height,
                                                  width: self.frame.width,
                                                  height: height))
        // 24 apps per page
        pageControl.numberOfPages = self.apps.count / 24
        self.addSubview(pageControl)
    }
    
    private func createMainAppCollectionView() {
        // Flow Layout
        let flowLayout = AppsLayout() //UICollectionViewFlowLayout()
        flowLayout.numberOfColumns = 4
        flowLayout.numberOfRows = 6


        // Because cell is slightly longer
//        flowLayout.minimumInteritemSpacing = APPSCELLSPACING/3
//
//        flowLayout.minimumLineSpacing = APPSCELLSPACING
//        flowLayout.scrollDirection = .horizontal
//        flowLayout.sectionInset = UIEdgeInsets(top: APPSCELLSPACING + 40, left: APPSCELLSPACING / 2, bottom: APPSCELLSPACING, right: APPSCELLSPACING/2)

        // Collection View
        let topInset: CGFloat = 50
        appsCollectionView = UICollectionView(frame: CGRect(x: 0, y: topInset, width: self.frame.width, height: self.frame.height - bottomAppBar.frame.height - pageControl.frame.height - topInset), collectionViewLayout: flowLayout)
        appsCollectionView.clipsToBounds = false
        appsCollectionView.backgroundColor = nil
        appsCollectionView.showsHorizontalScrollIndicator = false
        appsCollectionView.isPagingEnabled = true
        appsCollectionView.alwaysBounceHorizontal = true

        appsCollectionView.register(AppCell.self, forCellWithReuseIdentifier: "AppCell")

        appsCollectionView.delegate = self
        appsCollectionView.dataSource = self

        self.addSubview(appsCollectionView)
    }

    /*
     1) Create a bottom bar for apps
     2) Create page control, positioned on top of the bottom bar
     2) Creates a collection view for apps on top of page control
     */
    private func setup() {
        createBottomAppBar()
        createPageControl()
        createMainAppCollectionView()
    }

}

// MARK: - Collection View
extension AppsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.bottomAppBarCollectionView {

            let numberOfCells = CGFloat(bottomApps.count)

            // Calculate horizontal inset
            let cvWidth = collectionView.bounds.width
            let totalCellWidth = AppCell.cellWidth * numberOfCells
            let horizontalInset = (cvWidth - totalCellWidth) / numberOfCells

            if horizontalInset < 0 {
                return UIEdgeInsets.zero
            }

            let verticalInset: CGFloat = 6
            return UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
        }
        return UIEdgeInsets.zero
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.appsCollectionView {
            return self.apps.count
        } else {
            return self.bottomApps.count
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppCell", for: indexPath) as! AppCell
        cell.delegate = self
        cell.layer.cornerRadius = 10
        cell.innerContentColor = UIColor.randomFlatColor()
        
        // Setup cell
        if collectionView == self.appsCollectionView {
            cell.app = self.apps[indexPath.row]
        } else {
            cell.nameLabelHidden = true
            cell.app = self.bottomApps[indexPath.row]
        }

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        if collectionView == self.appsCollectionView {
            // Check for ongoing riddles
            guard let riddle = riddle else { return }
            switch riddle {
            case .evanEvanWhereAreYou, .stopHiding:
                // Only continue if Evan is NOT found yet
                if evanFound { return }

                if riddle == .evanEvanWhereAreYou {
                    if indexPath == randomIndexPath {
                        evanFound = true
                        print("You found Evan!")

                        beginAnimatingEvanIsFound(indexPathOfEvansCell: indexPath, inCollectionView: collectionView, {
                            self.delegate?.shouldHideAccessoryButton()
                        })
                    } else {
                        wrongGuesses += 1
                        print("Wrong.")
                    }
                } else if riddle == .stopHiding {

                    if indexPath == randomIndexPath {
                        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.transform = CGAffineTransform(scaleX: self.cellExpansionScale, y: self.cellExpansionScale)
                        }, completion: nil)
                        waitingForEvan = true
                    } else {
                        // Shirnk previously expanded cell, if exist.
                        guard let randomIndexPath = randomIndexPath, let cell = collectionView.cellForItem(at: randomIndexPath) else { return }
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.transform = CGAffineTransform.identity
                        }, completion: nil)
                        waitingForEvan = false

                        wrongGuesses += 1
                        print("Wrong.")
                    }
                }

                // When clicked on the cell Evan belonged to:
//                if indexPath == randomIndexPath {
//
//                    if riddle == .stopHiding {
//                        // If stop hiding,
//                        // cell expands,
//                        // `waitingForEvan` becomes true,
//                        // and waits for 90 degrees turn.
//                        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
//                        UIView.animate(withDuration: 0.3, animations: {
//                            cell.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//                        }, completion: nil)
//                        waitingForEvan = true
//                    } else {
//                        evanFound = true
//                        print("You found Evan!")
//
//                        beginAnimatingEvanIsFound(indexPathOfEvansCell: indexPath, inCollectionView: collectionView, {
//                            self.delegate?.shouldHideAccessoryButton()
//                        })
//                    }
//                } else {
//                    wrongGuesses += 1
//                    print("Wrong.")
//                }

                // If too many wrong guesses
                if wrongGuesses > maxWrongGuessCount {
                    print("Oops, too slow! Evan is now changing spots.")
                    wrongGuesses = 0
                    setupForRiddle(riddle)
                }
            }
        } else {

        }
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let cell = cell as! AppCell

        // If isOrganisingApps, but cell is not wiggling, wiggle it!
        if isOrganisingApps {
            cell.startWiggle()
        } else {
            cell.stopWiggle()
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let riddle = riddle else { return }

        let offsetX = scrollView.contentOffset.x

        switch riddle {
        case .evanEvanWhereAreYou, .stopHiding:
            guard let randIndexPath = randomIndexPath,
                let cell = appsCollectionView.cellForItem(at: randIndexPath) else { return }

            if !evanFound {
                let translateTransform = CGAffineTransform(translationX: offsetX * 2, y: 0)

                if riddle == .stopHiding && waitingForEvan {
                    // If its stopHiding riddle and we're waiting for Evan, the cell should be expanded
                    let scaleTransform = CGAffineTransform(scaleX: cellExpansionScale, y: cellExpansionScale)
                    cell.transform = translateTransform.concatenating(scaleTransform)
                } else {
                    cell.transform = translateTransform
                }
            }
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}

// MARK: - App cell touch gesture delegate
extension AppsView: AppCellTouchGestureDelegate {

    public func cellDidLongTapped(cell: AppCell) {
        if riddle == nil {
            startOrganisingApps()
        }
    }

    public func startOrganisingApps() {
        if !isOrganisingApps {
            isOrganisingApps = true
            for cell in self.appsCollectionView.visibleCells as! [AppCell] {
                cell.startWiggle()
            }
        }
    }

    public func stopOrganisingApps() {
        if isOrganisingApps {
            isOrganisingApps = false
            for cell in self.appsCollectionView.visibleCells as! [AppCell] {
                cell.stopWiggle()
            }
        }
    }

}

// MARK: - Animation functions for
extension AppsView {
    /// Animation for Evan is found
    private func beginAnimatingEvanIsFound(indexPathOfEvansCell indexPath: IndexPath, inCollectionView collectionView: UICollectionView, _ completion: (() -> Void)?) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        // Blocks interaction while animate Evan.
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: .curveEaseIn, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: { (_) in

            // Expand cell
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.4, options: .curveEaseOut, animations: {
                cell.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
            }, completion: { (_) in
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    cell.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    self.isUserInteractionEnabled = true
                    completion?()
                })
            })

            // Create evan
            let frames = [
                UIImage(named: "Animation/tap-0")!,
                UIImage(named: "Animation/tap-1")!,
                UIImage(named: "Animation/tap-2")!,
                UIImage(named: "Animation/tap-0")!,
                UIImage(named: "Animation/tap-0")!,
                UIImage(named: "Animation/tap-0")!,
                UIImage(named: "Animation/tap-0")!,
                UIImage(named: "Animation/tap-0")!
            ]
            let evanImageView = UIImageView(frame: cell.frame)
            evanImageView.image = UIImage.animatedImage(with: frames, duration: 1)
            evanImageView.layer.cornerRadius = evanImageView.bounds.width/2
            evanImageView.alpha = 0
            self.addSubview(evanImageView)

            // Scale factor of evan. (height / width)
            let evanScaledFactor: CGFloat = 35.0/21.0
            let evanWidth: CGFloat = 150.0
            let evanHeight: CGFloat = evanWidth * evanScaledFactor

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                evanImageView.frame = CGRect(x: 0, y: self.bottomAppBar.frame.origin.y - evanHeight, width: evanWidth, height: evanHeight)
                evanImageView.alpha = 1
            }, completion: { (_) in
                Utils.delay(by: 0.4, completion: {
                    self.delegate?.shouldCongratulate()

                    // Evan walks away after 5s
                    Utils.delay(by: 5, completion: {
                        evanImageView.image = UIImage.animatedImageNamed("Animation/walk-", duration: 1)
                        UIView.animate(withDuration: 2.5, animations: {
                            evanImageView.transform = CGAffineTransform(translationX: self.bounds.maxX + 100, y: 0)
                        }, completion: nil)
                    })
                })
            })
        })
    }
}














