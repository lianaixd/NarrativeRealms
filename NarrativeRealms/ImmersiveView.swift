import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Binding var tutorialStep: Int
    @State private var sceneEntity: Entity?

    var body: some View {
        RealityView { content in
            // Add the scene entity to the content if it has been loaded
            if let scene = sceneEntity {
                content.add(scene)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            loadFantasyScene()
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    // Apply the tap behavior on the tapped entity
                    _ = value.entity.applyTapForBehaviors()
                    print("🔹 Tap detected on entity: \(value.entity.name)")
                }
        )
    }

    private func loadFantasyScene() {
        Task {
            do {
                // Load the FantasyScene scene from the RealityKitContent bundle
                let scene = try await Entity.load(named: "FantasyScene", in: realityKitContentBundle)
                sceneEntity = scene
                print("✅ FantasyScene loaded successfully.")
            } catch {
                print("❌ Error loading FantasyScene: \(error.localizedDescription)")
            }
        }
    }
}
