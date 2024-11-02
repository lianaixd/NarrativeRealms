import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Binding var showTagTutorial: Bool // Binding to control the window size from the app level
    @State private var immersiveSpaceIsShown = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        if showTagTutorial {
            // Display the Tag tutorial window with reduced padding
            TagTutorialView()
                .padding(.horizontal, 0) // Reduce horizontal padding for the tutorial view
                .frame(maxWidth: .infinity, alignment: .center) // Center and restrict max width
        } else {
            // Main content view with reduced padding
            VStack {
                Model3D(named: "Scene", bundle: realityKitContentBundle)
                    .padding(.bottom, 30) // Adjust padding for vertical space

                Text("Build a story together")
                    .font(.title)

                HStack {
                    Button("New Story") {
                        Task {
                            // Open immersive space and switch to tutorial window
                            switch await openImmersiveSpace(id: "ImmersiveSpace") {
                            case .opened:
                                immersiveSpaceIsShown = true
                                showTagTutorial = true // Switch to the Tag tutorial window
                            case .error, .userCancelled:
                                fallthrough
                            @unknown default:
                                immersiveSpaceIsShown = false
                            }
                        }
                    }
                    .font(.title2)
                    .frame(minWidth: 220)

                    TextField("Enter a code", text: .constant(""))
                        .disabled(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 250)

                    Button("Join") {}
                        .font(.title2)
                        .disabled(true)
                        .frame(minWidth: 120)
                }
                .padding(.horizontal, 10) // Reduce horizontal padding for HStack
            }
            .padding(.vertical, 20) // Minimal vertical padding for overall view
            .frame(maxWidth: .infinity, alignment: .center) // Center and restrict max width
        }
    }
}

// Tag tutorial window as a separate view

#Preview(windowStyle: .automatic) {
    ContentView(showTagTutorial: .constant(false))
}
