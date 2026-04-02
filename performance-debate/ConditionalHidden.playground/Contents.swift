//: A UIKit based Playground for presenting user interface

import SwiftUI
import PlaygroundSupport

struct MyViewController: View {
    
    var body: some View {
        Text("Hello, World!")
    }
    
}
// Present the view controller in the Live View window
PlaygroundPage.current.setLiveView(MyViewController())

