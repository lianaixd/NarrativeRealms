import SwiftUI

// Define PaletteWindowID for window management
struct PaletteWindowID: Identifiable {
    var id: Int
}

@main
struct NarrativeRealmsApp: App {
    @State private var showTagTutorial = false // Controls whether the Tag tutorial is shown
    @State private var tutorialStep = 1 // Track the tutorial step across views

    var body: some Scene {
        WindowGroup {
            ContentView(showTagTutorial: $showTagTutorial, tutorialStep: $tutorialStep)
                .frame(width: showTagTutorial ? 300 : 640, height: showTagTutorial ? 500 : 360)
        }
        .windowStyle(DefaultWindowStyle())
        .defaultSize(width: showTagTutorial ? 300 : 640, height: showTagTutorial ? 500 : 360)

        // Separate WindowGroup for PaletteView, binding to tutorialStep for updates
        WindowGroup("Palette Window", for: PaletteWindowID.ID.self) { $id in
            PaletteView(tutorialStep: $tutorialStep)
        }
        .defaultSize(width: 340, height: 240) // Adjust to make the window smaller
        .windowResizability(.contentSize) // Limit resizability to the content size
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
        .defaultSize(width: 800, height: 600)

        ImmersiveSpace(id: "FantasyScene") {
            ImmersiveView()
        }
        .defaultSize(width: 1000, height: 700)
    }
}
