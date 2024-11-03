import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Binding var showTagTutorial: Bool
    @Binding var tutorialStep: Int
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var onRestart: () -> Void

    var body: some View {
        ZStack {
            if showTagTutorial {
                TagTutorialView(
                    tutorialStep: $tutorialStep,
                    onRestart: onRestart
                )
                .padding(.horizontal, 0)
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                // Main content view
                VStack {
                    Model3D(named: "Scene", bundle: realityKitContentBundle)
                        .padding(.bottom, 30)

                    Text("Build a story together")
                        .font(.title)

                    HStack {
                        Button("New Story") {
                            Task {
                                switch await openImmersiveSpace(id: "ImmersiveSpace") {
                                case .opened:
                                    immersiveSpaceIsShown = true
                                    showTagTutorial = true
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
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
