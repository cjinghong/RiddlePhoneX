import Foundation
import UIKit

public protocol AppsViewDelegate: class {
    func shouldShowAccessoryButton(withTitle title: String, position: Position, action: @escaping (() -> Void))
    func shouldHideAccessoryButton()
}

/// Screen containing scrollable apps.
public class AppsView: UIView {

    /// If the user is organizing apps 
    private(set) var isOrganisingApps: Bool = false {
        didSet {
            if isOrganisingApps {
                delegate?.shouldShowAccessoryButton(withTitle: "Done", position: .topRight, action: { [weak self] in
                    self?.stopOrganisingApps()
                })
            } else {
                delegate?.shouldHideAccessoryButton()
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

    /// Sets the apps immediately, replaces existing apps
    public func setApps(_ apps: [BaseApp]) {
        self.apps = apps
        self.appsCollectionView.reloadData()
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
        appsCollectionView.clipsToBounds = true
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

extension AppsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        if collectionView == appsCollectionView {
//
//        }
//        // Width to only containing 4 columns
//        var cols: CGFloat = 4
//        var w = (collectionView.frame.width / cols) - APPSCELLSPACING
//
//        // if width is too big, insert 1 more cell
//        while (w > 70) {
//            cols += 1
//            w = (collectionView.frame.width / cols) - APPSCELLSPACING
//        }
//
//        // Height is w + addtional for label
//        let h = w + 20
//        return CGSize(width: w, height: h)
//    }

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

        if collectionView == self.appsCollectionView {
            cell.app = self.apps[indexPath.row]
        } else {
            cell.nameLabelHidden = true
            cell.app = self.bottomApps[indexPath.row]
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: - Present app
        if collectionView == self.appsCollectionView {

        } else {

        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }



    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let cell = cell as! AppCell

        // If isOrganisingApps, but cell is not wiggling, wiggle it!
        if isOrganisingApps && !cell.wiggling {
            cell.startWiggle()
        } else {
            cell.stopWiggle()
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}

extension AppsView: AppCellTouchGestureDelegate {

    public func cellDidLongTapped(cell: AppCell) {
        startOrganisingApps()
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














