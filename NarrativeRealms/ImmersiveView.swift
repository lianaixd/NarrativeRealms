import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct TranscriptionPanel: Component {
    var text: String
}

extension ImmersiveView {
    private func createTextPanel(withText text: String) -> ModelEntity {
        let panel = ModelEntity(
            mesh: .generatePlane(width: 0.3, height: 0.2),
            materials: [SimpleMaterial(color: .white.withAlphaComponent(0.8), isMetallic: false)]
        )
        
        updateTextInPanel(panel: panel, text: text)
        panel.components[TranscriptionPanel.self] = TranscriptionPanel(text: text)
        
        return panel
    }
    
    private func updateTextInPanel(panel: ModelEntity, text: String) {
        panel.children.forEach { $0.removeFromParent() }
        
        let textEntity = ModelEntity()
        let textMesh = MeshResource.generateText(
            text.isEmpty ? "Listening..." : text,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.02),
            containerFrame: CGRect(x: -0.13, y: -0.08, width: 0.26, height: 0.16),
            alignment: .left,
            lineBreakMode: .byWordWrapping
        )
        textEntity.model = ModelComponent(mesh: textMesh, materials: [SimpleMaterial(color: .black, isMetallic: false)])
        panel.addChild(textEntity)
    }
    
    private func startNewPanel() {
           guard let scene = sceneEntity else { return }
           
           let panel = createTextPanel(withText: "")
           panel.position = SIMD3<Float>(0.3, 1.5, -1.0) // Fixed position for live panel
           
           scene.addChild(panel)
           currentPanel = panel
           
           cancellable = recordingManager.$transcribedText
               .receive(on: RunLoop.main)
               .sink { text in
                   if let panel = currentPanel {
                       updateTextInPanel(panel: panel, text: text)
                   }
               }
    }
    
    private func finalizePanel() {
            cancellable?.cancel()
            if let panel = currentPanel {
                // Remove the 3D panel
                panel.removeFromParent()
                currentPanel = nil
                
                // Create a window with the final text
                           DispatchQueue.main.async {
                               NotificationCenter.default.post(
                                   name: .createTranscriptionWindow,
                                   object: nil,
                                   userInfo: ["text": recordingManager.transcribedText]
                               )
                               print("📨 Posted transcription notification")
                           }
            }
        }
}

struct ImmersiveView: View {
    @Binding var tutorialStep: Int
    @State private var sceneEntity: Entity?
    @State private var isRecording = false
    @State private var currentPanel: ModelEntity?
    @State private var cancellable: AnyCancellable?
    @StateObject private var recordingManager = AudioRecordingManager()
    
    var body: some View {
          RealityView { content in
              if let scene = sceneEntity {
                              if let microphoneGroup = findMicrophoneGroup(in: scene) {
                                  print("🎤 Found microphone group: \(microphoneGroup.name)")
                                  makeAllMicrophonePartsInteractive(microphoneGroup)
                              } else {
                                  print("❌ Microphone group not found")
                              }
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
                             handleEntityTap(value.entity)
                         }
                 )
      }
    
    private func makeAllMicrophonePartsInteractive(_ groupEntity: Entity) {
        print("🎯 Setting up microphone interaction. Entity type: \(type(of: groupEntity))")
        
        // Calculate the overall bounds of the microphone group
        let bounds = groupEntity.visualBounds(relativeTo: groupEntity)
        
        // Create a slightly larger invisible collision box
        let padding: Float = 0.05  // Adjust this value to make the hit box bigger
        let hitBoxSize = SIMD3<Float>(
            bounds.max.x - bounds.min.x + padding * 2,
            bounds.max.y - bounds.min.y + padding * 2,
            bounds.max.z - bounds.min.z + padding * 2
        )
        
        var material = PhysicallyBasedMaterial()
        material.blending = .transparent(opacity: .init(floatLiteral: 0.0001))
        
        // Create an invisible ModelEntity for collision
        let hitBox = ModelEntity(
            mesh: .generateBox(size: hitBoxSize),
            materials: [material]
        )
        
        // Position the hit box to center it on the microphone
        hitBox.position = SIMD3<Float>(
            (bounds.min.x + bounds.max.x) / 2,
            (bounds.min.y + bounds.max.y) / 2,
            (bounds.min.z + bounds.max.z) / 2
        )
        
        // Make the hit box interactive
        hitBox.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: hitBoxSize)])
        hitBox.components.set(InputTargetComponent())
        hitBox.name = "microphone_hitbox"
        
        // Add the hit box as a child of the microphone group
        groupEntity.addChild(hitBox)
        
        print("📦 Created invisible hit box: \(hitBoxSize)")
    }
    
    private func makeEntityInteractive(_ entity: ModelEntity) {
        print("📦 Making entity interactive: \(entity.name)")
        let bounds = entity.visualBounds(relativeTo: entity)
        let boxShape = ShapeResource.generateBox(size: [
            max(0.001, bounds.max.x - bounds.min.x),  // Ensure non-zero size
            max(0.001, bounds.max.y - bounds.min.y),
            max(0.001, bounds.max.z - bounds.min.z)
        ])
        entity.collision = CollisionComponent(shapes: [boxShape])
        entity.components.set(InputTargetComponent())
    }
    
    // Helper function to print detailed entity information
    private func printEntityDetails(_ entity: Entity, depth: Int) {
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)Entity: \(entity.name), Type: \(type(of: entity))")
        
        // Print components if it's a ModelEntity
        if let modelEntity = entity as? ModelEntity {
            print("\(indent)  - Has Model Component: \(modelEntity.model != nil)")
            print("\(indent)  - Has Collision: \(modelEntity.collision != nil)")
            print("\(indent)  - Has Input Target: \(modelEntity.components[InputTargetComponent.self] != nil)")
        }
        
        // Recursively print children
        for child in entity.children {
            printEntityDetails(child, depth: depth + 1)
        }
    }

    private func handleEntityTap(_ entity: Entity) {
        print("🔹 Tap detected on entity: \(entity.name)")
        printEntityDetails(entity, depth: 0)  // Print details of tapped entity
        
        // Check if this entity or any of its parents is the microphone group
        var currentEntity: Entity? = entity
        while let current = currentEntity {
            if current.name == "microphone_tex_v01" {
                toggleRecording()
                if isRecording {
                    startNewPanel()
                } else {
                    finalizePanel()
                }
                break
            }
            currentEntity = current.parent
            print("👆 Checking parent entity: \(currentEntity?.name ?? "none")")
        }
    }
    
    private func findMicrophoneGroup(in entity: Entity) -> Entity? {
           if entity.name == "microphone_tex_v01" {
               return entity
           }
           
           for child in entity.children {
               if let found = findMicrophoneGroup(in: child) {
                   return found
               }
           }
           
           return nil
       }
    

    
    private func toggleRecording() {
            isRecording.toggle()
            print("🎤 \(isRecording ? "Started" : "Stopped") recording")
            
            if isRecording {
                try? recordingManager.startRecording()
            } else {
                recordingManager.stopRecording()
            }
        }
    
    private func updateMicrophoneVisuals(_ groupEntity: Entity, isRecording: Bool) {
           // Update all microphone parts
           for child in groupEntity.children {
               for modelPart in child.children {
                   if let modelEntity = modelPart as? ModelEntity {
                       var material = SimpleMaterial()
                       
                       if isRecording {
                           // Bright red with emissive glow
                           material.color = SimpleMaterial.BaseColor(tint: .red)
                           material.roughness = 0.0
                           material.metallic = 1.0
                           modelEntity.components.set(EmissiveMaterialComponent())
                       } else {
                           // Reset to normal appearance
                           material.color = SimpleMaterial.BaseColor(tint: .white)
                           material.roughness = 0.5
                           material.metallic = 0.0
                           modelEntity.components.remove(EmissiveMaterialComponent.self)
                       }
                       
                       modelEntity.model?.materials = [material]
                   }
               }
           }
       }
    
    private func loadFantasyScene() {
        Task {
            do {
                let scene = try await Entity.load(named: "FantasyScene", in: realityKitContentBundle)
                sceneEntity = scene
                print("✅ FantasyScene loaded successfully.")

            } catch {
                print("❌ Error loading FantasyScene: \(error.localizedDescription)")
            }
        }
    }
}

// Add notification name
extension Notification.Name {
    static let createTranscriptionWindow = Notification.Name("createTranscriptionWindow")
}

// Helper extension to print entity hierarchy
extension Entity {
    func printEntityHierarchy(depth: Int = 0) {
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)📦 Entity: \(self.name)")
        for child in children {
            child.printEntityHierarchy(depth: depth + 1)
        }
    }
}

struct EmissiveMaterialComponent: Component {}
