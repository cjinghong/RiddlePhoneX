import Foundation
import UIKit

public class AppCell: UICollectionViewCell {

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

    /// TODO: - Shows install animation
    public func animateInstall() {

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
//        appNameLabel.backgroundColor = .black
        appNameLabel.textAlignment = .center
        appNameLabel.text = "Nameless App"
        self.addSubview(appNameLabel)

        // Touch down
        let touchDown = UILongPressGestureRecognizer(target:self, action: #selector(didTouchDown(_:)))
        touchDown.minimumPressDuration = 0
        touchDown.cancelsTouchesInView = false
        self.addGestureRecognizer(touchDown)
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




}
