import SwiftUI

// Define PaletteWindowID for window management
struct PaletteWindowID: Hashable, Codable {
    var id: Int
}

@main
struct NarrativeRealmsApp: App {
    @State private var showTagTutorial = false
    @State private var tutorialStep = 1
    @State private var paletteWindowOpened = false

    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some Scene {
        // Main Content WindowGroup
        WindowGroup {
            ContentView(
                showTagTutorial: $showTagTutorial,
                tutorialStep: $tutorialStep,
                onRestart: resetToNewStory
            )
            .frame(
                width: showTagTutorial ? 300 : 640,
                height: showTagTutorial ? 500 : 360
            )
        }
        .windowStyle(DefaultWindowStyle())
        .defaultSize(
            width: showTagTutorial ? 300 : 640,
            height: showTagTutorial ? 500 : 360
        )
        .onChange(of: tutorialStep) { newStep in
            handleTutorialStepChange(newStep: newStep)
        }

        // PaletteView WindowGroup
        WindowGroup("Palette Window", for: PaletteWindowID.self) { id in
            PaletteView(tutorialStep: $tutorialStep)
        }
        .defaultSize(width: 640, height: 300)
        .windowResizability(.contentSize)

        // Immersive Spaces
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
        .defaultSize(width: 800, height: 600)

        ImmersiveSpace(id: "FantasyScene") {
            ImmersiveView()
        }
        .defaultSize(width: 1000, height: 700)
    }

    // Handle tutorial step changes
    func handleTutorialStepChange(newStep: Int) {
        if newStep == 3 && !paletteWindowOpened {
            paletteWindowOpened = true
            openWindow(value: PaletteWindowID(id: 1))
        }
    }

    func resetToNewStory() {
        Task {
            await dismissImmersiveSpace()
            showTagTutorial = false
            tutorialStep = 1
            paletteWindowOpened = false
            // Note: We cannot close the window programmatically, but resetting the state ensures it won't reopen unintentionally.
            NotificationCenter.default.post(name: .resetApp, object: nil)
        }
    }
}
