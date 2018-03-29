//: [Previous](@previous)

import UIKit
import PlaygroundSupport
var str = "Hello, playground"

//: [Next](@next)


let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
view.backgroundColor = .white

let confetti = SAConfettiView(frame: view.bounds)
view.addSubview(confetti)




PlaygroundPage.current.liveView = view
