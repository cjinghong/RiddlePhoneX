import Foundation
import UIKit

public protocol AppCellTouchGestureDelegate: class {
    func cellDidLongTapped(cell: AppCell)
}

public class AppCell: UICollectionViewCell {

    /// Cell height (Changes inner content view's frame)
    public static let cellWidth: CGFloat = 50

    weak var delegate: AppCellTouchGestureDelegate?

    public var app: BaseApp? {
        didSet {
            appIconImageView.image = app?.icon
            appNameLabel.text = app?.name
        }
    }

    public var nameLabelHidden: Bool = false {
        didSet {
            if nameLabelHidden {
                appNameLabel?.alpha = 0
            } else {
                appNameLabel?.alpha = 1
            }
        }
    }

    public override var isSelected: Bool {
        didSet {
            updateSelectedState(selected: isSelected)
        }
    }

    public var wiggling: Bool {
        get {
            return shouldWiggle
        }
    }

    /// The background colour of the rounded rectangle of the app icon.
    // If an image is available, the background colour will NOT be visible
    public var innerContentColor: UIColor = .white {
        didSet {
            innerContentView?.backgroundColor = innerContentColor
        }
    }

    /// ALL subviews should be inside the inner content view. The inner content view decides the size of the cell
    private var innerContentView: UIView!
    private var appNameLabel: UILabel!
    private var iconOverlayView: UIView!
    private var appIconImageView: UIImageView!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// Determines if the cell should be wiggling
    private var shouldWiggle = false
    /// Stops wiggling.
    public func stopWiggle() {
        shouldWiggle = false
        Utils.delay(by: 0.2) {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: { [weak self] in
                self?.innerContentView.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }

    /// Start wiggling with a delay. Default is random delay
    public func startWiggle() {
        if shouldWiggle == true { return }
        shouldWiggle = true
        animateWigglingIndefinitely()
    }

    private func animateWigglingIndefinitely(_ delay: TimeInterval = Double.random(min: 0, max: 0.3)) {

        // Remove all animations before starting to wiggle again
        self.innerContentView.layer.removeAllAnimations()
        if !shouldWiggle { return }

        let angle: CGFloat = 2 * CGFloat.pi / 180
        UIView.animate(withDuration: 0.1, delay: delay, options: [.curveEaseOut], animations: { [weak self] in
            self?.innerContentView.transform = CGAffineTransform(rotationAngle: -angle)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
                self?.innerContentView.transform = CGAffineTransform(rotationAngle: angle)
            }, completion: {[weak self] _ in
                self?.animateWigglingIndefinitely(0)
            })
        })
    }

    /// Adds a semitransparent uiview above the iconimageview
    private func updateSelectedState(selected: Bool) {
        if selected {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.iconOverlayView.alpha = 1
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.iconOverlayView.alpha = 0
            }, completion: nil)
        }
    }

    private func setup() {
        // Inner content view
        innerContentView = UIView(frame: CGRect(x: self.bounds.width/2 - AppCell.cellWidth/2, y: 0, width: AppCell.cellWidth, height: AppCell.cellWidth))
        innerContentView.backgroundColor = innerContentColor
        innerContentView.layer.cornerRadius = 10
        self.addSubview(innerContentView)

        // Square Image view for appicon
        appIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: innerContentView.frame.width, height: innerContentView.frame.height))
        appIconImageView.layer.cornerRadius = 10
        appIconImageView.clipsToBounds = true
        appIconImageView.contentMode = .scaleAspectFill
        innerContentView.addSubview(appIconImageView)

        // Creates an invisible icon overlay view that shows when the cell is selected
        iconOverlayView = UIView(frame: appIconImageView.frame)
        iconOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        iconOverlayView.layer.cornerRadius = 10
        iconOverlayView.clipsToBounds = true
        iconOverlayView.alpha = 0
        innerContentView.addSubview(iconOverlayView)

        // Label for app name
        let additionalLabelPadding: CGFloat = 20
        appNameLabel = UILabel(frame: CGRect(x: -additionalLabelPadding/2, y: appIconImageView.frame.size.height + 3, width: innerContentView.frame.width + additionalLabelPadding, height: 12))
        appNameLabel.textColor = .white
        appNameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        appNameLabel.textAlignment = .center
        appNameLabel.text = "Nameless App"

        if nameLabelHidden { appNameLabel.alpha = 0 }

        innerContentView.addSubview(appNameLabel)

        // Touch down
        let touchDown = UILongPressGestureRecognizer(target:self, action: #selector(didTouchDown(_:)))
        touchDown.delegate = self
        touchDown.minimumPressDuration = 0
        touchDown.cancelsTouchesInView = false
        self.addGestureRecognizer(touchDown)

        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(didLongTap(_:)))
        longTap.delegate = self
        longTap.minimumPressDuration = 1
        longTap.cancelsTouchesInView = false
        self.addGestureRecognizer(longTap)
    }

    @objc
    private func didTouchDown(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            updateSelectedState(selected: true)
        default:
            updateSelectedState(selected: false)
        }
    }

    @objc
    private func didLongTap(_ sender: UILongPressGestureRecognizer) {
        delegate?.cellDidLongTapped(cell: self)
    }


}

extension AppCell: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }


}



