import SwiftUI

// Define PaletteWindowID if not in scope
struct PaletteWindowID: Identifiable {
    var id: Int
}

@main
struct NarrativeRealmsApp: App {
    @State private var showTagTutorial = false // Controls whether the Tag tutorial is shown
    @State private var tutorialStep = 1 // Track the current tutorial step across views

    var body: some Scene {
        WindowGroup {
            ContentView(showTagTutorial: $showTagTutorial, tutorialStep: $tutorialStep)
                .frame(width: showTagTutorial ? 300 : 640, height: showTagTutorial ? 500 : 360)
        }
        .windowStyle(DefaultWindowStyle())
        .defaultSize(width: showTagTutorial ? 300 : 640, height: showTagTutorial ? 500 : 360)

        // Separate WindowGroup for PaletteView with tutorialStep binding
        WindowGroup("Palette Window", for: PaletteWindowID.ID.self) { $id in
            PaletteView(tutorialStep: $tutorialStep)
        }
        .defaultSize(width: 340, height: 240)
        .windowResizability(.contentSize) // Limit resizability to content size
        
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
