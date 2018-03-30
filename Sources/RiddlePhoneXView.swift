import Foundation
import UIKit
import AVFoundation

public enum Position {
    case topLeft, topRight
}

public class RiddlePhoneXView: UIView {

    private var mainFrame: UIView!

    private var bgmPlayer: AVAudioPlayer?
    private var soundEffectPlayer: AVAudioPlayer?
    private var secondarySoundEffectPlayer: AVAudioPlayer?
    private var volume: Float = 1

    /// The current riddle
    private var riddle: Riddle?

    /// Accessory button on the top left of the notch
    private(set) var topAccessoryButton: UIButton?

    private var notificationsView: UIView!

    /// Content view.
    /// All subviews should be added into the content view.
    private(set) var contentView: UIView!
    private var appsView: AppsView!

    /// Wallpaper
    private var wallpaperImageView: UIImageView!
    /// Lockscreen
    private var lockscreenImageView: UIImageView!

    /// Swipe down for notifications
    private var topBarView: UIView!
    
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
        frameImageView.clipsToBounds = true

        self.mainFrame = frameImageView
        self.addSubview(frameImageView)
    }

    private func createTopBar() {
        let marginTop = 53/1600 * frame.height
        let width = 0.4975 * frame.width
        let height = 55/1600 * frame.height
        let topBar: UIView = UIView(frame: CGRect(x: 0, y: marginTop, width: width, height: height))
        topBar.center.x = self.center.x
        topBar.backgroundColor = nil

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(swipedDownForNotifications(_:)))
        topBar.addGestureRecognizer(panGesture)

        self.addSubview(topBar)
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
        let wallpaperImageView = UIImageView(image: Wallpaper.uglyrainbow.image)
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

    private var dateTimer: Timer?
    private func createNotificationsView() {
        notificationsView = UIView(frame: contentView.frame)
        lockscreenImageView = UIImageView(frame: notificationsView.bounds)
        lockscreenImageView.image = Wallpaper.desert.image
        notificationsView.addSubview(lockscreenImageView)

        // Formatters
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM"

        // Time
        let timeLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 50, width: notificationsView.bounds.width, height: 80))
        timeLabel.font = UIFont.systemFont(ofSize: 80, weight: .thin)
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white
        timeLabel.text = timeFormatter.string(from: Date())
        notificationsView.addSubview(timeLabel)

        // Date
        let dateLabel: UILabel = UILabel(frame: CGRect(x: 0, y: timeLabel.frame.maxY, width: notificationsView.bounds.width, height: 18))
        dateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        dateLabel.textAlignment = .center
        dateLabel.textColor = .white
        dateLabel.text = dateFormatter.string(from: Date())
        notificationsView.addSubview(dateLabel)

        // Timer
        dateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (_) in
            timeLabel.text = timeFormatter.string(from: Date())
            dateLabel.text = dateFormatter.string(from: Date())
        })

        // Credits
        let creditsLabel: UILabel = UILabel(frame: CGRect(x: 0, y: dateLabel.frame.maxY + 40, width: notificationsView.bounds.width, height: 20))
        creditsLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        creditsLabel.textAlignment = .center
        creditsLabel.textColor = .white
        creditsLabel.text = "Credits"
        notificationsView.addSubview(creditsLabel)

        // Actual credits
        let credits: UITextView = UITextView(frame: CGRect(x: 0, y: creditsLabel.frame.maxY + 10, width: notificationsView.bounds.width, height: notificationsView.bounds.height - creditsLabel.frame.maxY - 10))
        credits.font = UIFont.systemFont(ofSize: 16)
        credits.textAlignment = .center
        credits.textColor = .white
        credits.backgroundColor = nil

        let string =
            "Background music by Eric Matyas\nConfetti by SAConfettiView\nEvan animations by Chan Jing Hong" as NSString

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrString = NSMutableAttributedString(string: string as String, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16),  NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle])
        let boldAttributes = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 16)]
        // Part of string to be bold
        attrString.addAttributes(boldAttributes, range: string.range(of: "Background music"))
        attrString.addAttributes(boldAttributes, range: string.range(of: "Confetti"))
        attrString.addAttributes(boldAttributes, range: string.range(of: "Evan animations"))
        credits.attributedText = attrString

        notificationsView.addSubview(credits)


        // Gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(swipedUpDismissNotifications(_:)))
        notificationsView.addGestureRecognizer(panGesture)

        // Hides notifications view
        notificationsView.transform = CGAffineTransform(translationX: 0, y: -notificationsView.frame.height)
        self.addSubview(notificationsView)
        self.insertSubview(notificationsView, belowSubview: mainFrame)
    }

    private func setup() {
        self.layer.cornerRadius = self.frame.width * 0.15
        self.clipsToBounds = true
        
        // Main frame, containing the iPhoneX image
        createMainFrame()

        // Swipe from top for notifications and stuff
        createTopBar()

        // Content view.
        createContentView()

        // Bottom bar for dismissing apps
        createBottomBarView()

        // Background wallpaper
        createBackgroundWallpaper()

        // Show appsview (home screen)
        createAppsView()

        // Create notifications view
        createNotificationsView()
    }

    // MARK: - Music and sounds
    private func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "Sounds/bgm", withExtension: "mp3") else { return }
        do {
            self.bgmPlayer = try AVAudioPlayer(contentsOf: url)
            self.bgmPlayer?.volume = self.volume
            self.bgmPlayer?.numberOfLoops = -1

            if self.bgmPlayer?.prepareToPlay() == true {
                self.bgmPlayer?.play()
            }
        } catch {
            print("\(error.localizedDescription)")
        }
    }

    public func playSecondaryBgm(url: URL, repeated: Bool = false) {
        do {
            self.secondarySoundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            self.secondarySoundEffectPlayer?.volume = self.volume
            self.secondarySoundEffectPlayer?.numberOfLoops = repeated ? -1 : 0

            if self.secondarySoundEffectPlayer?.prepareToPlay() == true {
                self.secondarySoundEffectPlayer?.play()
            }
        } catch {
            print("\(error.localizedDescription)")
        }
    }

    public func playSoundEffect(url: URL, repeated: Bool = false) {
        do {
            self.soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            self.soundEffectPlayer?.volume = self.volume
            self.secondarySoundEffectPlayer?.numberOfLoops = repeated ? -1 : 0

            if self.soundEffectPlayer?.prepareToPlay() == true {
                self.soundEffectPlayer?.play()
            }
        } catch {
            print("\(error.localizedDescription)")
        }
    }

    private func fadeVolume(forPlayer player: AVAudioPlayer?) {
        guard let player = player else { return }
        if (player.volume > 0.1) {
            player.volume = player.volume - 0.1
            Utils.delay(by: 0.1, completion: {
                self.fadeVolume(forPlayer: player)
            })
        } else {
            // Stop and get the sound ready for playing again
            player.stop()
            player.currentTime = 0
            player.prepareToPlay()
            player.volume = self.volume
        }
    }

    // MARK: - Show hide components functions
    private func showAccessoryButton(withTitle title: String, position: Position, action: (() -> Void)?) {
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

        // Action always includes hiding itself. Hides itself before calling completion block. So if the button needs to be displayed again, just call `shouldShowAccessoryButton` in the completion
        self.topAccessoryButton!.addAction(for: .touchUpInside) { [weak self] in
            self?.hideAccessoryButton()
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

    /// Showers confetti to congratulate winner
    private func congratulate() {
        let confetti = SAConfettiView(frame: contentView.bounds)
        confetti.isUserInteractionEnabled = false
        confetti.startConfetti()
        self.contentView.addSubview(confetti)

        if let url = Bundle.main.url(forResource: "Sounds/applause", withExtension: "mp3") {

            // Fade main player volume, applause.
            fadeVolume(forPlayer: bgmPlayer)
            playSecondaryBgm(url: url)
        }
    }

    @objc
    private func swipedUpDismissNotifications(_ sender: UIPanGestureRecognizer) {

        let translateY = sender.translation(in: contentView).y
        let percentage = abs(translateY / contentView.bounds.height)
        switch sender.state {
        case .changed:
            // Only when Y translate is more than 0, we do something.
            if translateY < 0 {
                // Negative translation, swiping up
                notificationsView.transform = CGAffineTransform(translationX: 0,
                                                                y: -(contentView.bounds.height * percentage + 20))
            }
        case .cancelled, .failed, .ended:
            // If above 30% of the content height, animate up
            if percentage > 0.3 {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.notificationsView.transform = CGAffineTransform(translationX: 0, y: -self.notificationsView.bounds.height)
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.notificationsView.transform = .identity
                }, completion: nil)
            }
            break
        default:
            break
        }
    }

    @objc
    private func swipedDownForNotifications(_ sender: UIPanGestureRecognizer) {

        if self.notificationsView.transform == .identity {
            // Unable to swipe down somemore.
            return
        }

        let translateY = sender.translation(in: contentView).y
        let percentage = abs(translateY / contentView.bounds.height)

        switch sender.state {
        case .changed:
            // Only when Y translate is more than 0, we do something.
            if translateY > 0 {
                notificationsView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.height * (percentage - 1) + 20)
            }
        case .cancelled, .failed, .ended:
            // If above 30% of the content height, animate down
            if percentage > 0.3 {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.notificationsView.transform = .identity
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.notificationsView.transform = CGAffineTransform(translationX: 0, y: -self.notificationsView.bounds.height)
                }, completion: nil)
            }
            break
        default:
            break
        }
    }

    @objc
    private func swipedUpToDismiss(_ sender: UIPanGestureRecognizer) {

        switch sender.state {
        case .changed:
            // Check for riddle
            if let riddle = self.riddle {
                let translateY = sender.translation(in: self).y
                let percentage = abs(translateY / self.frame.height)

                // Behaviour for riddle
                switch riddle {
                case .evanEvanWhereAreYou:
                    // Evan where are you have the same behaviour as normal
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
                        }
                    }
                case .stopHiding:
                    // Rotate it like maddd
                    let maxRadian: CGFloat = 360.0 * CGFloat.pi / 180.0
                    let currentRadian = (maxRadian * percentage)

                    let minScale: CGFloat = 0.5

                    // Current scale, with minimum of 0.5
                    var currentScale = 1 - percentage * 2 > minScale ? 1 - percentage * 2 : minScale

                    let scaleTransform = CGAffineTransform(scaleX: currentScale, y: currentScale)

                    contentView.transform = CGAffineTransform(rotationAngle: currentRadian).concatenating(scaleTransform)

                    let correctRotationDegrees: CGFloat = 90
                    let minRadianThreshold = (correctRotationDegrees - 10) * CGFloat.pi / 180.0
                    let maxRadianThreshold = (correctRotationDegrees + 10) * CGFloat.pi / 180.0

                    // If current radian is within range of
                    if currentRadian >= minRadianThreshold && currentRadian <= maxRadianThreshold {
                        appsView.evanShouldFall(true, gestureRecognizer: sender)
                    } else {
                        appsView.evanShouldFall(false, gestureRecognizer: sender)
                    }
                    break
                }
            } else {
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
                    }
                }
            }
        case .cancelled, .failed, .ended:

            // Behaviour for riddle.
            if let riddle = riddle {
                switch riddle {
                case .evanEvanWhereAreYou:
                    break
                case .stopHiding:
                    // Cancel falling if gesture released
                    appsView?.evanShouldFall(false, gestureRecognizer: sender)
                }
            }

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

    public func set(lockscreen: Wallpaper) {
        lockscreenImageView.image = lockscreen.image
    }

    /// Sets the default apps. No install animation will be shown
    public func set(apps: [BaseApp]) {
        appsView?.setApps(apps)
    }

    /// Install a given app
    public func install(app: BaseApp) {
        appsView?.install(app)
    }

    /// Uninstalls a given app
    public func uninstall(app: BaseApp) {
        appsView.uninstall(app)
    }

    /// Uninstalls ALL apps
    public func uninstallAllApps() {
        appsView.uninstallAllApps()
    }

    public func setupForRiddle(_ riddle: Riddle) {
        self.riddle = riddle

        playBackgroundMusic()

        switch riddle {
        case .evanEvanWhereAreYou, .stopHiding:
            appsView.setupForRiddle(riddle)
        }
    }
}

extension RiddlePhoneXView: AppsViewDelegate {

    /// Action always includes hiding itself. Hides itself before calling completion block. So if the button needs to be displayed again, just call `shouldShowAccessoryButton` in the completion
    public func shouldShowAccessoryButton(withTitle title: String, position: Position, action: @escaping (() -> Void)) {
        self.showAccessoryButton(withTitle: title, position: position, action: action)
    }

    public func shouldHideAccessoryButton() {
        self.hideAccessoryButton()
    }

    public func shouldCongratulate() {
        self.congratulate()
    }

    public func shouldPlaySoundEffect(soundUrl url: URL) {
        self.playSecondaryBgm(url: url)
    }

    public func contentViewShouldReturnToOriginal(delay: TimeInterval, _ completion: @escaping (() -> Void)) {
        UIView.animate(withDuration: 0.4, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: { [weak self] in
            self?.contentView.transform = CGAffineTransform.identity
            }, completion: { _ in
                completion()
        })
    }

    public func contentViewShouldRotateBy(_ degrees: CGFloat, delay: TimeInterval, _ completion: @escaping (() -> Void)) {
        UIView.animate(withDuration: 1, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: [.curveEaseIn], animations: { [weak self] in
            let radian = degrees * CGFloat.pi / 180.0
            self?.contentView.transform = CGAffineTransform(rotationAngle: radian)
            }, completion: { _ in
                completion()
        })
    }
    
}






