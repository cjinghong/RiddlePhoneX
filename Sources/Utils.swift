import Foundation
import UIKit

public extension Double {

    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }

    /// Random double between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random double point number between 0 and n max
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

public extension Int {

    /// Random double between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random double point number between 0 and n max
    public static func random(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)) + UInt32(min))
    }
}

public class Utils {
    public class func delay(by seconds: TimeInterval, completion: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {
            completion()
        })
    }
}

public extension UIColor {

    static let jigglyPuff = UIColor(red: 255.0/255.0, green: 159.0/255.0, blue: 243.0/255.0, alpha: 1.0)
    static let lotusPink = UIColor(red: 243.0/255.0, green: 104.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    static let jadeDust = UIColor(red: 2.0/255.0, green: 210.0/255.0, blue: 211.0/255.0, alpha: 1.0)
    static let aquaVelvet = UIColor(red: 0.0/255.0, green: 163.0/255.0, blue: 164.0/255.0, alpha: 1.0)
    static let casandoraYellow = UIColor(red: 254.0/255.0, green: 202.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    static let dragonSkin = UIColor(red: 255.0/255.0, green: 159.0/255.0, blue: 67.0/255.0, alpha: 1.0)
    static let joustBlue = UIColor(red: 84.0/255.0, green: 160.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let blueDeFrance = UIColor(red: 46.0/255.0, green: 134.0/255.0, blue: 222.0/255.0, alpha: 1.0)
    static let pastelRed = UIColor(red: 255.0/255.0, green: 107.0/255.0, blue: 107.0/255.0, alpha: 1.0)
    static let amourRed = UIColor(red: 238.0/255.0, green: 82.0/255.0, blue: 83.0/255.0, alpha: 1.0)
    static let nasuPurple = UIColor(red: 94.0/255.0, green: 54.0/255.0, blue: 205.0/255.0, alpha: 1.0)
    static let blueBell = UIColor(red: 51.0/255.0, green: 36.0/255.0, blue: 151.0/255.0, alpha: 1.0)
    static let megaman = UIColor(red: 72.0/255.0, green: 219.0/255.0, blue: 251.0/255.0, alpha: 1.0)
    static let cyanite = UIColor(red: 12.0/255.0, green: 189.0/255.0, blue: 227.0/255.0, alpha: 1.0)
    static let caribbeanGreen = UIColor(red: 30.0/255.0, green: 209.0/255.0, blue: 161.0/255.0, alpha: 1.0)
    static let mountainMeadow = UIColor(red: 17.0/255.0, green: 172.0/255.0, blue: 132.0/255.0, alpha: 1.0)
    static let fuelTown = UIColor(red: 87.0/255.0, green: 101.0/255.0, blue: 116.0/255.0, alpha: 1.0)
    static let imperialPrimer = UIColor(red: 34.0/255.0, green: 47.0/255.0, blue: 62.0/255.0, alpha: 1.0)

    static let canadianPalleteColours: [UIColor] = [
        UIColor.jigglyPuff, UIColor.lotusPink,
        UIColor.jadeDust, UIColor.aquaVelvet,
        UIColor.casandoraYellow, UIColor.dragonSkin,
        UIColor.joustBlue, UIColor.blueDeFrance,
        UIColor.pastelRed, UIColor.amourRed,
        UIColor.nasuPurple, UIColor.blueBell,
        UIColor.megaman, UIColor.cyanite,
        UIColor.caribbeanGreen, UIColor.mountainMeadow,
        UIColor.fuelTown, UIColor.imperialPrimer
    ]

    class func randomFlatColor() -> UIColor {
        let randInt = Int.random(min: 0, max: canadianPalleteColours.count)
        return canadianPalleteColours[randInt]
    }
}

public class ClosureSleeve {
    let closure: () -> ()

    init(attachTo: AnyObject, closure: @escaping () -> ()) {
        self.closure = closure
        objc_setAssociatedObject(attachTo, "[\(arc4random())]", self, .OBJC_ASSOCIATION_RETAIN)
    }

    @objc func invoke() {
        closure()
    }
}

extension UIControl {
    func addAction(for controlEvents: UIControlEvents, action: @escaping () -> ()) {
        let sleeve = ClosureSleeve(attachTo: self, closure: action)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
    }
}
