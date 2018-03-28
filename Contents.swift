import UIKit
import PlaygroundSupport

/*:
 # Playgrounds X

 I fell in love with all the different animations you can find in the IPhone X, and I've decided to make a playground demonstrating the different animations.

 ### Creating the iPhone X.
 */
let iphoneX = IPhoneXView(diagonal: 800)
/*:
 ### Setting a new wallpaper

 You can choose from a preset of wallpapers by using `Wallpaper.waves` or `Wallpaper.redBlue`
 */
//iphoneX.set(wallpaper: Wallpaper.desert)
//iphoneX.set(wallpaper: Wallpaper.aurora)
//iphoneX.set(wallpaper: Wallpaper.mountains)

var apps = [BaseApp]()

for i in 0...30 {
    apps.append(BaseApp(contentView: UIView(), name: "\(i)"))
}

iphoneX.set(apps: apps)
iphoneX.install(app: BaseApp(contentView: UIView(), name: "Suck"))
iphoneX.install(app: BaseApp(contentView: UIView(), name: "Suck"))
iphoneX.install(app: BaseApp(contentView: UIView(), name: "Suck"))
iphoneX.install(app: BaseApp(contentView: UIView(), name: "Suck"))
iphoneX.install(app: BaseApp(contentView: UIView(), name: "Suck"))



// Testing accessory button
//iphoneX.showAccessoryButton(withTitle: "Done", position: .topRight) {
//    iphoneX.showAccessoryButton(withTitle: "Test 2", position: .topLeft, action: {
//        iphoneX.hideAccessoryButton()
//    })
//}


//
//let myVeryOwnApp: App?
//iphoneX.installApp(myApp)


















PlaygroundPage.current.liveView = iphoneX

