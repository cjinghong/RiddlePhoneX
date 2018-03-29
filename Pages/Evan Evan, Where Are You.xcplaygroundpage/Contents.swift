import UIKit
import PlaygroundSupport

/*:
 ### Table of Contents

 1. [Introduction](Introduction)
 2. **[Evan Evan, Where are you?](Evan%20Evan,%20Where%20Are%20You)**
 3. [Stop Hiding!](Stop%20Hiding)
 4. [On a serious note](On%20a%20serious%20note)
 - - -
 [Previous](@previous)
 */
/*:
 # Evan Evan, where are you?
 Your job is to find **Evan**. I won't tell you how exactly, but I've provided some hints. Whenever you get stuck, just press on the *Solve* button on the top left of the RiddlePhoneX to harness the power of Steve Jobs and solve the puzzle immediately.

 Goodluck!
 */
let riddlePhoneX = RiddlePhoneXView(diagonal: 800)
riddlePhoneX.set(wallpaper: Wallpaper.aurora)
riddlePhoneX.setupForRiddle(Riddle.evanEvanWhereAreYou)
/*:
 ## Hint #1
 Evan love to *stand out* from the crowd.
 */
//:
/*:
 ## Hint #2
 Swipe around the screen, do you notice anything *different*?
 */



//: ### So you've found Evan? Time to move on.
//: [Next](@next)






PlaygroundPage.current.liveView = riddlePhoneX
