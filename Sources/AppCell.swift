import Foundation
import UIKit

public protocol AppCellTouchGestureDelegate: class {
    func cellDidLongTapped(cell: AppCell)
}

public class AppCell: UICollectionViewCell {

    weak var delegate: AppCellTouchGestureDelegate?

    public var app: BaseApp? {
        didSet {
            appIconImageView.image = app?.icon
            appNameLabel.text = app?.name
        }
    }

    public override var isSelected: Bool {
        didSet {
            updateSelectedState(selected: isSelected)
        }
    }

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

    // MARK: - Animations
    /// TODO: - Shows install animation
    public func animateInstall() {

    }

    private var shouldWiggle = true

    public func stopWiggle() {
        shouldWiggle = false
        Utils.delay(by: 0.2) {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: {
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }

    /// Start wiggling with a delay. Default is random delay
    public func startWiggle() {
        shouldWiggle = true
        animateWigglingIndefinitely()
    }

    private func animateWigglingIndefinitely(_ delay: TimeInterval = Double.random(min: 0, max: 0.3)) {
        if !shouldWiggle { return }

        let angle: CGFloat = 2 * CGFloat.pi / 180
        UIView.animate(withDuration: 0.1, delay: delay, options: [.curveEaseOut], animations: {
            self.transform = CGAffineTransform(rotationAngle: -angle)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
                self.transform = CGAffineTransform(rotationAngle: angle)
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
        // Square Image view for appicon
        appIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.width))
        appIconImageView.contentMode = .scaleAspectFill
        appIconImageView.backgroundColor = .white
        appIconImageView.clipsToBounds = true
        appIconImageView.layer.cornerRadius = 10
        self.addSubview(appIconImageView)

        // Creates an invisible icon overlay view that shows when the cell is selected
        iconOverlayView = UIView(frame: appIconImageView.frame)
        iconOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        iconOverlayView.layer.cornerRadius = 10
        iconOverlayView.clipsToBounds = true
        iconOverlayView.alpha = 0
        self.addSubview(iconOverlayView)

        // Label for app name
        let additionalLabelPadding: CGFloat = 20
        appNameLabel = UILabel(frame: CGRect(x: -additionalLabelPadding/2, y: appIconImageView.frame.size.height + 3, width: frame.width + additionalLabelPadding, height: 12))
        appNameLabel.textColor = .white
        appNameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        appNameLabel.textAlignment = .center
        appNameLabel.text = "Nameless App"
        self.addSubview(appNameLabel)

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



