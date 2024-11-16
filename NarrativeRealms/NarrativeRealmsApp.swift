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
    @State private var transcriptionWindows: Set<TranscriptionWindowID> = []
    @State private var nextTranscriptionID = 0
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    init() {
            setupNotifications()  // Initialize notification observer when app starts
        }

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
                height: showTagTutorial ? 500 : 520
            )
        }
        .windowStyle(DefaultWindowStyle())
        .defaultSize(
            width: showTagTutorial ? 300 : 640,
            height: showTagTutorial ? 500 : 460
        )
        .onChange(of: tutorialStep) { newStep in
            handleTutorialStepChange(newStep: newStep)
        }

        // TagTutorialView WindowGroup
        WindowGroup("Tag Tutorial") {
            TagTutorialView(tutorialStep: $tutorialStep, onRestart: resetToNewStory)
                .frame(width:300, height:400)
        }
        .defaultSize(width: 300, height: 400) // Adjusted to fit TagTutorialView content better
        .windowResizability(.contentSize) // Allows the window to resize based on content

        // PaletteView WindowGroup
        WindowGroup("Palette Window", for: PaletteWindowID.self) { id in
            PaletteView(tutorialStep: $tutorialStep)
        }
        .defaultSize(width: 640, height: 400)
        .windowResizability(.contentSize)

        // Immersive Space
        ImmersiveSpace(id: "FantasyScene") {
            ImmersiveView(tutorialStep: $tutorialStep)
        }
        .defaultSize(width: 1000, height: 700)
        
        // Speech to Text transcription window group
        WindowGroup(for: TranscriptionWindowID.self) { $windowID in
                    if let id = windowID {
                        TranscriptionView(text: id.text)
                    }
                }
                .defaultSize(width: 400, height: 300)
                .windowStyle(.automatic)
                .windowResizability(.contentSize)
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
            NotificationCenter.default.post(name: .resetApp, object: nil)
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .createTranscriptionWindow,
            object: nil,
            queue: .main
        ) { notification in
            if let text = notification.userInfo?["text"] as? String {
                createNewTranscriptionWindow(withText: text)
            }
        }
    }
    
    func createNewTranscriptionWindow(withText text: String) {
           let windowID = TranscriptionWindowID(id: nextTranscriptionID, text: text)
           transcriptionWindows.insert(windowID)
           nextTranscriptionID += 1
           openWindow(value: windowID)
       }
    
    private func getTranscriptionText(for windowID: TranscriptionWindowID) -> String {
        // In a real app, you'd want to store and retrieve the text for each window ID
        return "Transcription \(windowID.id)"
    }
    
}
