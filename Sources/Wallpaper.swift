import Foundation
import UIKit

public class Wallpaper {

    // Wallpaper presets
    public class var waves: Wallpaper {
        get {
            return Wallpaper(fromImage: UIImage(named: "Wallpapers/waves")!)
        }
    }
    public class var redBlue: Wallpaper {
        get {
            return Wallpaper(fromImage: UIImage(named: "Wallpapers/redBlue")!)
        }
    }
    public class var mountain: Wallpaper {
        get {
            return Wallpaper(fromImage: UIImage(named: "Wallpapers/mountain")!)
        }
    }

    public var image: UIImage

    public init(fromImage image: UIImage) {
        self.image = image
    }

}

