import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Binding var tutorialStep: Int
    @State private var sceneEntity: Entity?

    var body: some View {
        RealityView { content in
            loadFantasyScene(into: content)
        }
        .edgesIgnoringSafeArea(.all)
    }

    func loadFantasyScene(into content: RealityViewContent) {
        Task {
            do {
                // Load the FantasyScene scene from the RealityKitContent bundle
                let scene = try await Entity.load(named: "FantasyScene", in: realityKitContentBundle)
                sceneEntity = scene
                content.add(scene)
                print("✅ FantasyScene loaded successfully.")
            } catch {
                print("❌ Error loading FantasyScene: \(error.localizedDescription)")
            }
        }
    }
}
