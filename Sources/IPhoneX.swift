import Foundation
import UIKit

public class IPhoneXView: UIView {

    /// Content view.
    /// All subviews should be added into the content view.
    private(set) var contentView: UIView!
    private var bottomBarView: UIView!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    /// Init with `diagonal`. This is the measurement of the screen diagonally
    public convenience init(diagonal: CGFloat) {
        let width = diagonal * 2.236125
        let height = diagonal * 1.1180625
        self.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        // IPHONE X FRAME
        // Creates iPhone X frame
        let frameImageView = UIImageView(image: UIImage(named: "iphonexframe"))
        frameImageView.frame = frame
        frameImageView.contentMode = .scaleToFill
        self.addSubview(frameImageView)


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
        let bottomBarImage = UIImageView(image: UIImage(named: "bottombar"))
        let imageHeight = barHeight * 1 / 7
        let imageWidth = barWidth * 7 / 17
        bottomBarImage.frame.size.height = imageHeight
        bottomBarImage.frame.size.width = imageWidth
        bottomBarImage.center.x = bottomBarView.frame.width/2
        bottomBarImage.center.y = bottomBarView.frame.height/2
        bottomBarView.addSubview(bottomBarImage)

        self.bottomBarView = bottomBarView
        self.addSubview(bottomBarView)


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
        contentView.backgroundColor = .gray

        self.contentView = contentView
        self.insertSubview(contentView, belowSubview: frameImageView)
    }
}
