import SwiftUI
import RealityKit
import RealityKitContent // Ensure this is correctly imported if using a custom bundle

struct ImmersiveView: View {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Binding var tutorialStep: Int
    @State private var modelEntity: Entity?

    var body: some View {
        RealityView { content in
            // 'make' closure: called once to set up the content
            if tutorialStep == 1 {
                do {
                    // Load the model entity asynchronously without the file extension
                    let entity = try await Entity.load(named: "dude-normal_tex_v01", in: realityKitContentBundle)
                    modelEntity = entity
                    positionModel()
                    content.add(modelEntity!)
                } catch {
                    print("Error loading model: \(error)")
                }
            }
        } update: { content in
            // 'update' closure: called whenever the view updates
            if tutorialStep == 1 {
                if let modelEntity = modelEntity {
                    // Ensure the model is visible and positioned correctly
                    modelEntity.isEnabled = true
                    positionModel()
                }
            } else {
                // Hide the model when not in tutorial step 1
                if let modelEntity = modelEntity {
                    modelEntity.isEnabled = false
                }
            }
        }
        .onChange(of: tutorialStep) { newStep in
            // Update model position or visibility when tutorial step changes
            if newStep == 1 {
                positionModel()
            } else {
                // Optionally hide the model
                if let modelEntity = modelEntity {
                    modelEntity.isEnabled = false
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    /// Positions and scales the model in the immersive view based on the tutorial step
    func positionModel() {
        guard let modelEntity = modelEntity else { return }

        // Define the position for tutorial step 1
        let newTranslation = SIMD3<Float>(x: 0.5, y: 0.0, z: -1.0)
        let newScale = SIMD3<Float>(1.0, 1.0, 1.0) // Normal scale

        // Apply the transform without animation
        modelEntity.transform = Transform(
            scale: newScale,                          // Scale first
            rotation: modelEntity.transform.rotation, // Retain existing rotation
            translation: newTranslation               // Translation after scale
        )

        // Ensure the model is enabled and visible
        modelEntity.isEnabled = true

        // Optional: Log the transform for debugging
        print("Model Position: \(modelEntity.transform.translation)")
        print("Model Scale: \(modelEntity.transform.scale)")
    }
}
