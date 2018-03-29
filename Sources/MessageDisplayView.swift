import UIKit

public class MessageDisplayView: UIView {

    public enum MessageDisplayType {
        case success
        case failure
        case normal
    }

    public enum Direction {
        case bottomToTop
        case topToBottom
        case leftToRight
        case rightToLeft
        case expand
    }

    private var parentView: UIView?
    private var anchoredToView: UIView?

    private var type: MessageDisplayType = .normal
    private let animDuration: TimeInterval = 0.3
    public var animationDirection: Direction = .expand

    private var preAnimationTransform: CGAffineTransform {
        get {
            var transform = CGAffineTransform.identity
            switch animationDirection {
            case .leftToRight:
                transform = CGAffineTransform(translationX: -self.bounds.width/2, y: 0)
            case .rightToLeft:
                transform = CGAffineTransform(translationX: self.bounds.width/2, y: 0)
            case .topToBottom:
                transform = CGAffineTransform(translationX: 0, y: -self.bounds.height)
            case .bottomToTop:
                transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
            case .expand:
                transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
            return transform
        }
    }

    private var message: String = ""
    private var label: UILabel!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Creates a `MessageDisplayView` that is anchored to another UIView.
    /// The `MessageDisplayView will be laid on top of the given UIView, and vertically centered
    /// Keep in mind the `anchoredTo` view MUST be one of the subview(s) of the `parentView` that the MessageDisplayView belongs to.
    public init(parentView: UIView, anchoredTo view: UIView, type: MessageDisplayType = .normal, message: String) {
        let width: CGFloat = 210
        let height: CGFloat = 50
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))

        self.center = view.center
        self.frame.origin.y = view.frame.origin.y - height - 10

        // Variables
        self.type = type
        self.message = message
        self.parentView = parentView
        self.anchoredToView = view

        setup()
    }

    private func setup() {
        // Setup view
        self.layer.cornerRadius = 10
        var color = UIColor.joustBlue

        switch type {
        case .success:
            color = .mountainMeadow
        case .failure:
            color = .amourRed
        case .normal:
            color = .joustBlue
        }
        self.backgroundColor = color

        // Setup label
        label = UILabel(frame: self.bounds)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.text = message

        self.addSubview(label)
    }

    public func show(after delay: TimeInterval = 0) -> MessageDisplayView {
        guard let parentView = parentView, let anchoredToView = anchoredToView else { return self }

        self.alpha = 0
        self.transform = preAnimationTransform

        parentView.insertSubview(self, belowSubview: anchoredToView)

        UIView.animate(withDuration: animDuration, delay: delay, options: .curveEaseInOut, animations: {
            self.alpha = 1
            self.transform = .identity
        }, completion: nil)

        return self
    }

    /// This WILL remove the message display view from the superview.
    public func hide(_ animated: Bool = true, after delay: TimeInterval = 0) {
        if animated {
            UIView.animate(withDuration: animDuration, delay: delay, options: .curveEaseInOut, animations: {
                self.alpha = 0
                self.transform = self.preAnimationTransform
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }

    /// Creates a `MessageDisplayView`, adds it to the `in` view, then returns the `MessageDisplayView`.
    public class func show(in parentView: UIView, anchoredToView anchoredView: UIView, message: String, type: MessageDisplayType, animated: Bool = true) -> MessageDisplayView {

        let mdv = MessageDisplayView(parentView: parentView, anchoredTo: anchoredView, type: type, message: message)

        if animated {
            mdv.alpha = 0
            mdv.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            parentView.addSubview(mdv)

            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                mdv.alpha = 1
                mdv.transform = .identity
            }, completion: nil)
        } else {
            parentView.addSubview(mdv)
        }

        return mdv
    }

}



