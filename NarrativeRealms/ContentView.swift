import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Binding var showTagTutorial: Bool
    @Binding var tutorialStep: Int
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace

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
                    Model3D(named: "logo_animation", bundle: realityKitContentBundle) { model in
                        model
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 300, height: 300)

                    Text("Build a story together")
                        .font(.title)
                        .padding(.bottom, 10)

                    HStack {
                        Button("New Story") {
                            Task {
                                switch await openImmersiveSpace(id: "FantasyScene") {
                                case .opened:
                                    immersiveSpaceIsShown = true
                                    showTagTutorial = true
                                    tutorialStep = 1
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
                    .padding(.vertical, 40)
                }
                .padding(.vertical, 40)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
