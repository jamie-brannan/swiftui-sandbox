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
              List {
                Section {
                  NavigationLink {
                    OldViewControllerContainer(
                      horizontalSizeClass: horizontalSizeClass,
                      verticalSizeClass: verticalSizeClass
                    )
                    .navigationTitle("Legacy UIKit")
                    .navigationBarTitleDisplayMode(.inline)
                  } label: {
                    uiKitItem
                  }
                } header: {
                  Text("Sample code in order of priority")
                }
                Section {
                  Text("TBD")
                  Text("TBD")
                  Text("TBD")
                } header: {
                  Text("Relevant Apple Developer ressources")
                }
              }
            }
            .navigationTitle("Resizing Hybrid")
            .navigationSubtitle("Guide to Xcode 27 resizing while between frameworks")
        }
    }

  var uiKitItem: some View {
    Label(title: {
      VStack(alignment: .leading) {
        Text("What happens to UIKit legacy")
        Text("`UIViewControllerRepresentable rendered according to `SizeClass` updates")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }, icon: {
      Image(systemName: "1.circle")
    })
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
