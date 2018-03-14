//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport



// Image is 1:2 ratio
//let width = 350
//let height = width * 2
//let iphoneX = IPhoneXView(frame: CGRect(x: 0, y: 0, width: width, height: height))
let iphoneX = IPhoneXView(diagonal: 1800)

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = iphoneX
