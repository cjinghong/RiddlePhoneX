//: [Previous](@previous)

import UIKit
import PlaygroundSupport
var str = "Hello, playground"

//: [Next](@next)


let view = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
view.backgroundColor = .green
//
//let confetti = SAConfettiView(frame: view.bounds)
//view.addSubview(confetti)
let subview = UIView(frame: CGRect.init(x: 0, y: 0, width: 300, height: 300))
subview.center = view.center
subview.backgroundColor = .black
view.addSubview(subview)

let mdv = MessageDisplayView(parentView: view, anchoredTo: subview, type: .success, message: "Hello everyone")

Utils.delay(by: 1) {
    mdv.animationDirection = .bottomToTop
    mdv.show()
}

//MessageDisplayView.show(in: view, anchoredToView: subview, message: "Evan is found", type: .success)


PlaygroundPage.current.liveView = view

