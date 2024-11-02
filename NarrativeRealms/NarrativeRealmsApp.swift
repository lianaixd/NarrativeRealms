import SwiftUI

// Define PaletteWindowID if not in scope
struct PaletteWindowID: Identifiable {
    var id: Int
}

@main
struct NarrativeRealmsApp: App {
    @State private var showTagTutorial = false // Controls whether the Tag tutorial is shown

    var body: some Scene {
        WindowGroup {
            ContentView(showTagTutorial: $showTagTutorial)
                .frame(width: showTagTutorial ? 300 : 640, height: showTagTutorial ? 500 : 360)
        }
        .windowStyle(DefaultWindowStyle())
        .defaultSize(width: showTagTutorial ? 300 : 640, height: showTagTutorial ? 500 : 360)

        // Separate WindowGroup for PaletteView
        WindowGroup("Palette Window", for: PaletteWindowID.ID.self) { $id in
            PaletteView()
        }

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
