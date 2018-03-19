import UIKit
import PlaygroundSupport

/*:
 # Playgrounds X

 I fell in love with all the different animations you can find in the IPhone X, and I've decided to make a playground demonstrating the different animations.

 ### Creating the iPhone X.
 */
//let iphoneX = IPhoneXView(diagonal: 800)

// Try changing it to a custom size!
//let iphoneX = IPhoneXView(frame: CGRect(x: 0, y: 0, width: 500, height: 700))

let iphoneX = IPhoneXView(diagonal: 800)
/*:
 ### Setting a new wallpaper

 You can choose from a preset of wallpapers by using `Wallpaper.waves` or `Wallpaper.redBlue`
 */
//iphoneX.set(wallpaper: Wallpaper.waves)
//iphoneX.set(wallpaper: Wallpaper.redBlue)
//iphoneX.set(wallpaper: Wallpaper.mountain)

// INSTALLING APPS
let apps: [BaseApp] = [
    BaseApp(contentView: UIView(), name: "Hello World"),
    BaseApp(contentView: UIView(), name: "Hello 2"),
    BaseApp(contentView: UIView(), name: "Hello 3", icon: UIImage(named: "sampleicon"))
]
iphoneX.install(apps: apps)
//
//let myVeryOwnApp: App?
//iphoneX.installApp(myApp)













PlaygroundPage.current.liveView = iphoneX

