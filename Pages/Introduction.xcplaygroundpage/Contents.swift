import UIKit
import PlaygroundSupport
/*:
 ### Table of Contents

 1. **[Introduction](Introduction)**
 2. [Evan Evan, Where are you?](Evan%20Evan,%20Where%20Are%20You)
 3. [Stop Hiding!](Stop%20Hiding)
 4. [On a serious note](On%20a%20serious%20note)
 - - -
 */
/*:
 # RiddlePhone X

 I know this *looks* like an iPhoneX, but trust me, it's not. This is a riddle game, with **lots** of unexpected twist an turns. Enjoy.
*/
/*:
 ## Welcome to the RiddlePhone X.
*/
let riddlePhoneX = RiddlePhoneXView(diagonal: 800)
/*:
 ### A beautiful wallpaper

 Oh god that is an awful looking background. Let's change the wallpaper. Try uncommenting the lines below and explore the different wallpapers that is available.
 */

//riddlePhoneX.set(wallpaper: Wallpaper.desert)
//riddlePhoneX.set(wallpaper: Wallpaper.aurora)
//riddlePhoneX.set(wallpaper: Wallpaper.mountains)


/*:
 ### What the apps?!

 What do you call an iPhone without cool apps?

 .

 .

 .

 I actually don't know the answer to that one. It's probably called an *Endroid*, or something. Nevermind let's start installing some apps!
 */
// I'm creating 30 apps using what's called a for-loop, and then installing all 30 apps into my brand new prankPhoneX Why? Because I can, that's why.
var apps = [BaseApp]()
for i in 0..<30 {
    apps.append(BaseApp(contentView: UIView(), name: "\(i)"))
}

// Actually installing the apps
riddlePhoneX.set(apps: apps)
/*:
 ### Starting fresh

 You know what? 30 apps that does nothing doesn't really get me excited, you know what I mean? Let's uninstall them.
 */
// Uninstalling all existing apps
riddlePhoneX.uninstallAllApps()
/*:
 #### Now that you've gotten a hang of it, let's get into the game...
 */
//: [Next](@next)











PlaygroundPage.current.liveView = riddlePhoneX
