import UIKit
import PlaygroundSupport
var str = "Hello, playground"

/*:
 ### Table of Contents

 1. [Introduction](Introduction)
 2. [Evan Evan, Where are you?](Evan%20Evan,%20Where%20Are%20You)
 3. [Stop Hiding!](Stop%20Hiding)
 4. **[On a serious note](On%20a%20serious%20note)**
 - - -
 [Previous](@previous)
 */
/*:
 # On a serious note,
 There is so much more puzzles that I've thought of to put into this project, but with the limited time constraint, this is all I'm able to come up with.

 Thanks for reviewing my submission, I hope you've enjoyed playing with this Playground as much as I enjoyed making it.
 */
/*:
 ## Some more features to point out (if you haven't discover them already)
 - Tap and hold the apps to *wiggle* them
 - Swipe down from the top to see *credits*
 */
let riddlePhoneX = RiddlePhoneXView(diagonal: 800)


riddlePhoneX.set(wallpaper: Wallpaper(fromImage: UIImage(named: "Wallpapers/wwdc18")!))

var apps: [BaseApp] = [
    BaseApp(name: "Hope", icon: UIImage(named: "AppIcon/W")),
    BaseApp(name: "That", icon: UIImage(named: "AppIcon/W")),
    BaseApp(name: "I", icon: UIImage(named: "AppIcon/D")),
    BaseApp(name: "Can", icon: UIImage(named: "AppIcon/C")),

    BaseApp(name: "Win", icon: UIImage(named: "AppIcon/2")),
    BaseApp(name: "The", icon: UIImage(named: "AppIcon/0")),
    BaseApp(name: "Scholarship", icon: UIImage(named: "AppIcon/1")),
    BaseApp(name: "This Year!", icon: UIImage(named: "AppIcon/8"))
]


riddlePhoneX.set(apps: apps)





PlaygroundPage.current.liveView = riddlePhoneX

