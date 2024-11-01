import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @State private var showTagTutorial = false // Controls which view to display
    @State private var immersiveSpaceIsShown = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        if showTagTutorial {
            // Tag tutorial window
            TagTutorialView()
                .frame(width: 400, height: 500) // Set size for tutorial window
                .transition(.opacity) // Smooth transition
        } else {
            // Main content view
            VStack {
                Model3D(named: "Scene", bundle: realityKitContentBundle)
                    .padding(.bottom, 50)

                Text("Build a story together")
                    .font(.title)

                HStack {
                    Button("New Story") {
                        Task {
                            // Open immersive space and show tutorial window
                            switch await openImmersiveSpace(id: "ImmersiveSpace") {
                            case .opened:
                                immersiveSpaceIsShown = true
                                showTagTutorial = true // Show the Tag tutorial window
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
                .padding(40)
            }
        }
    }
}

// Tag tutorial window as a separate view
struct TagTutorialView: View {
    var body: some View {
        VStack {
            Circle()
                .fill(Color.gray.opacity(0.5)) // Placeholder for Tag's image
                .frame(width: 100, height: 100) // Circle diameter

            Text("Tag")
                .font(.headline)
                .padding(.top, 8)

            Text("Hi, I'm Tag! I'll be your guide. Let's write a story together!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Divider()

            Button("Let's go!") {
                // Action to advance the tutorial
            }
            .padding(.vertical, 8)
            .buttonStyle(.borderedProminent)

            Button("Skip tutorial") {}
                .disabled(true)
                .padding(.top, 4)
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
