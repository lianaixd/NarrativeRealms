import SwiftUI
import RealityKit
import RealityKitContent // Ensure this is correctly imported if using a custom bundle

struct ImmersiveView: View {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Binding var tutorialStep: Int
    @State private var modelEntity: Entity?

    var body: some View {
        RealityView { content in
            // Add a TextEntity as a visual indicator of the immersive space being active
            let textEntity = createTextEntity(text: "Immersive Space Active", color: .green)
            content.add(textEntity)

            // Load the model when tutorialStep is 1
            if tutorialStep == 1 {
                do {
                    let entity = try await Entity.load(named: "dude-normal_tex_v01", in: realityKitContentBundle)
                    modelEntity = entity
                    positionModel()
                    content.add(modelEntity!)
                } catch {
                    print("Error loading model: \(error)")
                }
            }
        } update: { content in
            if tutorialStep == 1 {
                modelEntity?.isEnabled = true
                positionModel()
            } else {
                modelEntity?.isEnabled = false
            }
        }
        .onChange(of: tutorialStep) { newStep in
            if newStep == 1 {
                positionModel()
            } else {
                modelEntity?.isEnabled = false
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    /// Helper function to create a TextEntity for display
    private func createTextEntity(text: String, color: UIColor) -> Entity {
        let mesh = MeshResource.generateText(text,
                                             extrusionDepth: 0.02,
                                             font: .systemFont(ofSize: 0.1),
                                             containerFrame: .zero,
                                             alignment: .center,
                                             lineBreakMode: .byTruncatingTail)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let textEntity = ModelEntity(mesh: mesh, materials: [material])
        textEntity.position = SIMD3<Float>(0, 0.5, -0.5) // Position it in view
        return textEntity
    }

    /// Positions and scales the model in the immersive view based on the tutorial step
    func positionModel() {
        guard let modelEntity = modelEntity else { return }

        let newTranslation = SIMD3<Float>(x: 0.5, y: 0.0, z: -1.0)
        let newScale = SIMD3<Float>(1.0, 1.0, 1.0)

        modelEntity.transform = Transform(
            scale: newScale,
            rotation: modelEntity.transform.rotation,
            translation: newTranslation
        )
        modelEntity.isEnabled = true

        print("Model Position: \(modelEntity.transform.translation)")
        print("Model Scale: \(modelEntity.transform.scale)")
    }
}
