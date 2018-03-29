//: [Previous](@previous)

import UIKit
import PlaygroundSupport

/*:
 # Evan Evan, where are you?
 Your job is to find **Evan**. I won't tell you how exactly, but there are hints written all over the place. Whenever you get stuck, just press on the *Solve* button on the top left of the RiddlePhoneX.

 Goodluck!
 */
let riddlePhoneX = RiddlePhoneXView(diagonal: 800)
riddlePhoneX.set(wallpaper: Wallpaper.aurora)
riddlePhoneX.setupForRiddle(Riddle.evanEvanWhereAreYou)

/*:
 ## Hint #1
 Evan love to stand out from the crowd.
 */





//: ### So you've found Evan? Time to move on.
//: [Next](@next)






PlaygroundPage.current.liveView = riddlePhoneX
