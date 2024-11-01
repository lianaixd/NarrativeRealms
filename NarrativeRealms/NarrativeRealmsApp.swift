import SwiftUI

@main
struct NarrativeRealmsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 640, height: 360) // Adjust size for main content window
        }
        .windowStyle(DefaultWindowStyle())
        .defaultSize(width: 640, height: 360) // Initial size for the main window

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
        .defaultSize(width: 800, height: 600) // Set a custom size for this immersive space

        ImmersiveSpace(id: "FantasyScene") {
            ImmersiveView()
        }
        .defaultSize(width: 1000, height: 700) // Different size for FantasyScene immersive space
    }
}
