import Foundation
import UIKit

public enum Position {
    case topLeft, topRight
}

public class IPhoneXView: UIView {

    private var mainFrame: UIView!

    /// Accessory button on the top left of the notch
    private(set) var topAccessoryButton: UIButton?

    /// Content view.
    /// All subviews should be added into the content view.
    private(set) var contentView: UIView!

    private var appsView: AppsView!

    /// Wallpaper
    private var wallpaperImageView: UIImageView!

    /// Swipe up to quit apps
    private var bottomBarView: UIView!
    /// The "line" image inside bottom bar view
    private var bottomBarImage: UIImageView!
    private var bottomBarHidden: Bool {
        get {
            return bottomBarImage.alpha == 0
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    /// Init with `diagonal`. This is the measurement of the screen diagonally
    public init(diagonal: CGFloat) {
        let width = diagonal / 2.236125
        let height = diagonal / 1.1180625
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    // MARK: - Creating components functions
    /// Main frame is the most front view
    private func createMainFrame() {
        // IPHONE X FRAME
        // Creates iPhone X frame
        var image = UIImage(named: "iphonexframe")

        // Ratio is the bigger number of the width and height divided by the smaller number
        var ratio = frame.width / frame.height
        if frame.height > frame.width {
            ratio = frame.height / frame.width
        }

        // If ratio is less than 1.5, use a square image instead
        if ratio < 1.5 {
            image = UIImage(named: "iphonexframe-square")
        }

        let frameImageView = UIImageView(image: image)
        frameImageView.frame = frame
        frameImageView.contentMode = .scaleToFill

        self.mainFrame = frameImageView
        self.addSubview(frameImageView)
    }

    /// Inserts a transparent content view BELOW mainFrame
    private func createContentView() {
        // CONTENT VIEW
        // Content view margins
        let cvMarginLeft = 0.075 * frame.width
        let cvMarginRight = 0.07625 * frame.width
        let cvMarginTop = 0.033125 * frame.height
        let cvMarginBottom = 0.043125 * frame.height

        // Content view frame
        let x = cvMarginLeft
        let y = cvMarginTop
        let width = frame.width - cvMarginLeft - cvMarginRight
        let height = frame.height - cvMarginTop - cvMarginBottom

        // Inserts content view behind frame
        let contentView = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        self.contentView = contentView
        self.insertSubview(contentView, belowSubview: mainFrame)
    }

    /// Inserts a background wallpaper BELOW contentView
    private func createBackgroundWallpaper() {
        // Background wallpaper
        let wallpaperImageView = UIImageView(image: Wallpaper.desert.image)
        wallpaperImageView.contentMode = .scaleAspectFill
        wallpaperImageView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height + bottomBarView.frame.height)
        self.wallpaperImageView = wallpaperImageView
        self.insertSubview(wallpaperImageView, belowSubview: contentView)
    }

    /// Creates a bottom bar view
    private func createBottomBarView() {
        // BOTTOM BAR VIEW
        // Creates swipe up to dismiss app view
        let barMarginSides = 0.075 * frame.width
        let barMarginBottom = 0.03625 * frame.height
        let barWidth = frame.width - (barMarginSides * 2)
        let barHeight = 0.04375 * frame.height

        let bottomBarView = UIView(frame:
            CGRect(x: barMarginSides,
                   y: frame.height - barMarginBottom - barHeight,
                   width: barWidth,
                   height: barHeight)
        )

        // Adds image
        bottomBarImage = UIImageView(image: UIImage(named: "bottombar"))
        let imageHeight = barHeight * 1 / 7
        let imageWidth = barWidth * 7 / 17
        bottomBarImage.frame.size.height = imageHeight
        bottomBarImage.frame.size.width = imageWidth
        bottomBarImage.center.x = bottomBarView.frame.width/2
        bottomBarImage.center.y = bottomBarView.frame.height/2
        bottomBarView.addSubview(bottomBarImage)

        // Gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(swipedUpToDismiss(_:)))
        bottomBarView.addGestureRecognizer(panGesture)
        self.bottomBarView = bottomBarView
        self.insertSubview(bottomBarView, belowSubview: mainFrame)
    }

    private func createAppsView() {
        // Create appsView if needed
        let frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        self.appsView = AppsView(frame: frame, delegate: self)
        // Show appsView if needed
        if self.appsView!.superview == nil {
            contentView.addSubview(self.appsView!)
        }

        // Hide bar when appview is showing
        hidesBottomBar()
    }

    // MARK: - Show hide components functions
    private func showAccessoryButton(withTitle title: String, position: Position, action: (() -> Void)?) {

        print("Show button")
        let mainFrameWidth = self.mainFrame.frame.width

        var x: CGFloat = 18
        let y: CGFloat = 5
        let w: CGFloat = mainFrameWidth * 100/800
        let h: CGFloat = 18

        switch position {
        case .topLeft:
            break
        case .topRight:
            x = self.contentView.frame.width - x - w
        }

        // Remove existing button from superview (if available), Create a new button everytime
        self.topAccessoryButton?.removeFromSuperview()

        self.topAccessoryButton = UIButton(frame: CGRect(x: x, y: y, width: w, height: h))
        self.topAccessoryButton!.layer.cornerRadius = h/2
        self.topAccessoryButton!.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        self.topAccessoryButton!.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        self.topAccessoryButton!.setTitleColor(.black, for: .normal)

        // Hidden at first, while waiting to animate
        self.topAccessoryButton!.alpha = 0
        self.contentView.addSubview(topAccessoryButton!)

        // Shrink, change title, then appears
        self.topAccessoryButton!.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.topAccessoryButton!.setTitle(title, for: .normal)
        self.topAccessoryButton!.addAction(for: .touchUpInside) {
            action?()
        }

        // Animate button appear
        self.topAccessoryButton!.alpha = 1
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { [weak self] in
            self?.topAccessoryButton!.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    private func hideAccessoryButton() {
        guard let button = self.topAccessoryButton else { return }

        // Animate button disappear
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { _ in
            button.removeFromSuperview()
        })
    }

    private func hidesBottomBar(_ animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {[weak self] in
                self?.bottomBarImage.alpha = 0
            }, completion: nil)
        } else {
            bottomBarImage.alpha = 0
        }
    }

    private func showsBottomBar(_ animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
                self?.bottomBarImage.alpha = 1
            }, completion: nil)
        } else {
            bottomBarImage.alpha = 1
        }
    }

    private func setup() {
        createMainFrame()

        createContentView()
        createBottomBarView()

        createBackgroundWallpaper()

        // Show appsview (home screen)
        createAppsView()
    }

    @objc
    private func swipedUpToDismiss(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            let translateY = sender.translation(in: self).y
            let percentage = translateY / self.frame.height * 2

            // If less than 0, swiping up.
            if percentage < 0 && 1 + percentage > 0.7 {
                let scale = (1 + percentage) - (percentage * 0.6)
                contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
            } else if 1 + percentage <= 0.7 {
                // If apps view is organising apps, dont show multitask,
                // instead end the gesture, and end organising apps
                if appsView?.isOrganisingApps == true {
                    sender.isEnabled = false
                    appsView?.stopOrganisingApps()
                } else {
                    // TODO: - If more than 0.7, time to pop multitask
                    print("Boom! Multitask baby")
                }
            }
        case .cancelled, .failed, .ended:
            sender.isEnabled = true // Re-enable gesture
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: { [weak self] in
                self?.contentView.transform = CGAffineTransform.identity
            }, completion: nil)
            contentView.transform = CGAffineTransform.identity
        default:
            break
        }
    }

    // MARK: - Public methods
    public func set(wallpaper: Wallpaper) {
        wallpaperImageView.image = wallpaper.image
    }

    /// Sets the default apps. No install animation will be shown
    public func set(apps: [BaseApp]) {
        appsView?.setApps(apps)
    }

    /// Install a given app
    public func install(app: BaseApp) {
        appsView?.install(app)
    }

}

extension IPhoneXView: AppsViewDelegate {

    public func shouldShowAccessoryButton(withTitle title: String, position: Position, action: @escaping (() -> Void)) {
        self.showAccessoryButton(withTitle: title, position: position, action: action)
    }

    public func shouldHideAccessoryButton() {
        self.hideAccessoryButton()
    }
    
}






