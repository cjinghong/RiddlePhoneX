import Foundation
import UIKit

public class Wallpaper {

    // Wallpaper presets
    public class var aurora: Wallpaper {
        get {
            return Wallpaper(fromImage: UIImage(named: "Wallpapers/aurora")!)
        }
    }
    public class var desert: Wallpaper {
        get {
            return Wallpaper(fromImage: UIImage(named: "Wallpapers/desert")!)
        }
    }
    public class var mountains: Wallpaper {
        get {
            return Wallpaper(fromImage: UIImage(named: "Wallpapers/mountains")!)
        }
    }
    public class var uglyrainbow: Wallpaper {
        get {
            return Wallpaper(fromImage: UIImage(named: "Wallpapers/uglyrainbow")!)
        }
    }

    public var image: UIImage

    public init(fromImage image: UIImage) {
        self.image = image
    }

}

