import Foundation
import UIKit

/// All new apps should extend the `BaseApp` class
public class BaseApp: UIView {

    var name: String = "Nameless app"
    var icon: UIImage? = UIImage(named: "sampleicon")!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(name: "Nameless app", icon: nil)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup(name: "Nameless app", icon: nil)
    }

    /// Size of the app. Should be the parent content view.
    public init(contentView: UIView, name: String, icon: UIImage? = nil) {
        super.init(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height))
        setup(name: name, icon: icon)
    }

    public init(name: String, icon: UIImage? = nil) {
        super.init(frame: CGRect.zero)
        setup(name: name, icon: icon)
    }

    private func setup(name: String, icon: UIImage?) {
        self.name = name
        self.icon = icon
    }

}
