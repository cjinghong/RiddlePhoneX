import UIKit

public enum Riddle {
    case evanEvanWhereAreYou
        // 1. Apps collection view
        // 2. When collection view is getting scrolled,
        //    all the apps move in the same direction
        // 3. Except for a single app, which moves in the opposite direction of the scroll

    case stopHiding
        // 1. Find Evan similarly to the first riddle.
        // 2. Evan wouldn't come out when tapped on, instead, the cell just expands.
        // 3. Rotate the view by swiping from the bottom to 90 degrees
        // 4. Hold it for 1 second
        // 5. Evan will fall out
}

