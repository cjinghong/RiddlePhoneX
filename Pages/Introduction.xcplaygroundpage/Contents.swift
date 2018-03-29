import UIKit
import PlaygroundSupport
/*:
 ### Table of Contents

 1. [Introduction](Introduction)
 2. [Evan Evan, Where are you?](Evan%20Evan,%20Where%20Are%20You)
 3. [On a serious note](On%20a%20serious%20note)


 */
/*:
 # Prankphone X

 This project is exactly the same as an iPhone X. But only with several slightly-unexpected features, or shall I say that the entire device is full of unexpected twist and turns..?
*/
/*:
 ## ACT 1 - Welcome to the Prankphone X.
*/
let prankPhoneX = PrankPhoneXView(diagonal: 800)
/*:
 ### A beautiful wallpaper

 Oh god that was an awful looking background. Let's try changing the wallpapers. Try uncommenting the lines below and explore the different wallpapers that is available.
 */
prankPhoneX.set(wallpaper: Wallpaper.desert)
//prankPhoneX.set(wallpaper: Wallpaper.aurora)
//prankPhoneX.set(wallpaper: Wallpaper.mountains)
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

prankPhoneX.set(apps: apps)
/*:
 ### Starting fresh

 You know what? 30 apps that does nothing doesn't really get me excited, you know what I mean? Let's uninstall them.
 */
// Uninstalling all existing apps
//prankPhoneX.uninstallAllApps()
/*:
 #### Now that you've gotten a hang of it, let's get into the game...
 */
//: [Next](@next)











PlaygroundPage.current.liveView = prankPhoneX
