import UIKit
import PlaygroundSupport

/*:
 ### Table of Contents

 1. [Introduction](Introduction)
 2. [Evan Evan, Where are you?](Evan%20Evan,%20Where%20Are%20You)
 3. **[Stop Hiding!](Stop%20Hiding)**
 4. [On a serious note](On%20a%20serious%20note)
 - - -
 [Previous](@previous)
 */
/*:
 # Stop hiding!
 Oh gosh. There he goes again. Evan is gone. Use what you've learnt before to find him. But this time, its going to be even harder. But of course, there's a "Solve" button on the top lefts if you feel like giving up 😏

 祝你好运!
 */
let riddlePhoneX = RiddlePhoneXView(diagonal: 800)
riddlePhoneX.set(wallpaper: Wallpaper.mountains)
riddlePhoneX.setupForRiddle(Riddle.stopHiding)

/*:
 ## Hint #1
 Tapping on the correct app that Evan is in seems to only expand it...

 How else could we get Evan out of the box?
 */
/*:
 ## Hint #2
 Here's a little poem:

 *When you swipe up,*

 *I'd spin around;*

 *Stop me at 90,*

 *And the lost will be found.*
 */
//:
/*:
 ## Hint #3
 Swipe from the bottom, like an iPhone X to blow your mind. Now refer back to **Hint #1**
 */



//: ### So you've found Evan? Time to move on.
//: [Next](@next)






PlaygroundPage.current.liveView = riddlePhoneX





