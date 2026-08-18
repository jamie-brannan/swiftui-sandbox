import SwiftUI
import Playgrounds

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("SwiftUI")
                    .font(.largeTitle.bold())

                NavigationLink {
                    OldViewControllerContainer(
                        horizontalSizeClass: horizontalSizeClass,
                        verticalSizeClass: verticalSizeClass
                    )
                    .navigationTitle("Legacy UIKit")
                    .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Label("Open legacy ViewController", systemImage: "arrow.right.square")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Resizing Hybrid")
            .navigationSubtitle("Guide to Xcode 27 resizing while between frameworks")
        }
    }
}

private struct OldViewControllerContainer: UIViewControllerRepresentable {
    let horizontalSizeClass: UserInterfaceSizeClass?
    let verticalSizeClass: UserInterfaceSizeClass?

    func makeUIViewController(context: Context) -> OldViewController {
        OldViewController()
    }

    func updateUIViewController(
        _ viewController: OldViewController,
        context: Context
    ) {
        viewController.update(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }
}

#Preview {
    ContentView()
}
