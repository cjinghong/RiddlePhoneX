import Foundation
import UIKit

public class AppCell: UICollectionViewCell {

    public var app: BaseApp? {
        didSet {
            appIconImageView.image = app?.icon
            appNameLabel.text = app?.name
        }
    }

    private var appNameLabel: UILabel!
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

    private func setup() {
        // Square Image view for appicon
        appIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.width))
        appIconImageView.contentMode = .scaleAspectFill
        appIconImageView.backgroundColor = .white
        appIconImageView.clipsToBounds = true
        appIconImageView.layer.cornerRadius = 10
        self.addSubview(appIconImageView)

        // Label for app name
        let additionalLabelPadding: CGFloat = 20
        appNameLabel = UILabel(frame: CGRect(x: -additionalLabelPadding/2, y: appIconImageView.frame.size.height + 3, width: frame.width + additionalLabelPadding, height: 12))
        appNameLabel.textColor = .white
        appNameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//        appNameLabel.backgroundColor = .black
        appNameLabel.textAlignment = .center
        appNameLabel.text = "Nameless App"
        self.addSubview(appNameLabel)
    }


}
