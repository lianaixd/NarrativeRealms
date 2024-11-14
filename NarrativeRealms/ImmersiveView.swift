import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Binding var tutorialStep: Int
    @State private var sceneEntity: Entity?
    @State private var isRecording = false
    @StateObject private var recordingManager = AudioRecordingManager()
    
    var body: some View {
          RealityView { content in
              if let scene = sceneEntity {
                  if let microphoneEntity = findMicrophone(in: scene) {
                      print("🎤 Found microphone entity: \(microphoneEntity.name)")
                      makeMicrophoneInteractive(microphoneEntity)
                  } else {
                      print("❌ Microphone entity not found")
                  }
                  
                  content.add(scene)
              }
          }
          .edgesIgnoringSafeArea(.all)
          .onAppear {
              loadFantasyScene()
          }
      }
    
    private func findMicrophone(in entity: Entity) -> Entity? {
        // Check if this is the microphone entity
        if entity.name == "microphone_tex_v01" {
            // Then find its first microphone child
                        for child in entity.children {
                            if child.name == "microphone" {
                                // Get the actual model (the nested microphone entity)
                                if let modelEntity = child.children.first(where: { $0.name == "microphone" }) {
                                    return modelEntity
                                }
                            }
                        }
        }
        
        // Check children recursively
        for child in entity.children {
            if let found = findMicrophone(in: child) {
                return found
            }
        }
        
        return nil
    }
    
    private func makeMicrophoneInteractive(_ entity: Entity) {
           if let modelEntity = entity as? ModelEntity {
               print("🎤 Making microphone interactive")
               
               // Add collision
               let bounds = modelEntity.visualBounds(relativeTo: modelEntity)
               let boxShape = ShapeResource.generateBox(size: [bounds.max.x - bounds.min.x,
                                                             bounds.max.y - bounds.min.y,
                                                             bounds.max.z - bounds.min.z])
               modelEntity.collision = CollisionComponent(shapes: [boxShape])
               
               // Add interaction components
               modelEntity.components.set(InputTargetComponent())
               
               // Make it grabbable
               modelEntity.components.set(PhysicsBodyComponent())
               
               // Add system gesture handlers
               modelEntity.components.set(GrabComponent())
               
               // Add tap handler
               modelEntity.components.set(TapComponent { entity in
                   if let modelEntity = entity as? ModelEntity {
                       toggleRecording(modelEntity)
                   }
               })
               
               print("✅ Added interaction components to microphone")
           }
       }
    
    private func handleEntityTap(_ entity: Entity) {
        print("🔹 Tap detected on entity: \(entity.name)")
        
        // Check if this is our microphone entity or one of its children
        var currentEntity: Entity? = entity
        while let current = currentEntity {
            if current.name == "microphone" {
                if let modelEntity = current as? ModelEntity {
                    toggleRecording(modelEntity)
                } else {
                    print("⚠️ Found microphone entity but it's not a ModelEntity")
                }
                break
            }
            currentEntity = current.parent
        }
    }
    
    private func toggleRecording(_ micEntity: ModelEntity) {
            isRecording.toggle()
            print("🎤 \(isRecording ? "Started" : "Stopped") recording")
            
            if isRecording {
                try? recordingManager.startRecording()
                
                var material = SimpleMaterial()
                material.color = SimpleMaterial.BaseColor(tint: .red)
                micEntity.model?.materials = [material]
            } else {
                recordingManager.stopRecording()
                
                var material = SimpleMaterial()
                material.color = SimpleMaterial.BaseColor(tint: .white)
                micEntity.model?.materials = [material]
            }
        }
    
    private func loadFantasyScene() {
        Task {
            do {
                let scene = try await Entity.load(named: "FantasyScene", in: realityKitContentBundle)
                sceneEntity = scene
                print("✅ FantasyScene loaded successfully.")
                
                // Debug: Print the initial hierarchy
                scene.printEntityHierarchy()
            } catch {
                print("❌ Error loading FantasyScene: \(error.localizedDescription)")
            }
        }
    }
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

// Components for system interactions
struct TapComponent: Component {
    let action: (Entity) -> Void
    
    init(action: @escaping (Entity) -> Void) {
        self.action = action
    }
}

struct GrabComponent: Component { }
