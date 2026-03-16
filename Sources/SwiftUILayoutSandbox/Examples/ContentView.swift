import SwiftUI

/// Top-level view that navigates between each layout experiment.
public struct ContentView: View {

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                NavigationLink("FlowLayout – tag cloud") {
                    ScrollView {
                        FlowLayoutExample()
                    }
                    .navigationTitle("FlowLayout")
                }
                NavigationLink("RadialLayout – circular ring") {
                    ScrollView {
                        RadialLayoutExample()
                    }
                    .navigationTitle("RadialLayout")
                }
                NavigationLink("MasonryLayout – staggered grid") {
                    ScrollView {
                        MasonryLayoutExample()
                    }
                    .navigationTitle("MasonryLayout")
                }
            }
            .navigationTitle("SwiftUI Layout Sandbox")
        }
    }
}

#Preview {
    ContentView()
}
