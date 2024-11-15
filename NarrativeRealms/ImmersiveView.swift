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
        
        let textEntity = ModelEntity()
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
        
        let xOffset: Float = Float(panelCount % 3) * 0.35
        let yOffset: Float = Float((panelCount / 3) % 3) * 0.25
        let panel = createTextPanel(withText: "")
        panel.position = SIMD3<Float>(xOffset, 1.5 + yOffset, -1.0)
        
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
            updateTextInPanel(panel: panel, text: recordingManager.transcribedText)
            currentPanel = nil
            panelCount += 1
        }
    }
}

struct ImmersiveView: View {
    @Binding var tutorialStep: Int
    @State private var sceneEntity: Entity?
    @State private var isRecording = false
    @State private var panelCount = 0
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
           // Make all children interactive
           for child in groupEntity.children {
               for modelPart in child.children {
                   if let modelEntity = modelPart as? ModelEntity {
                       print("Making interactive: \(modelEntity.name)")
                       let bounds = modelEntity.visualBounds(relativeTo: modelEntity)
                       let boxShape = ShapeResource.generateBox(size: [bounds.max.x - bounds.min.x,
                                                                     bounds.max.y - bounds.min.y,
                                                                     bounds.max.z - bounds.min.z])
                       modelEntity.collision = CollisionComponent(shapes: [boxShape])
                       modelEntity.components.set(InputTargetComponent())
                   }
               }
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
    
    private func handleEntityTap(_ entity: Entity) {
           print("🔹 Tap detected on entity: \(entity.name)")
           
           // Check if this entity is part of the microphone group
           var currentEntity: Entity? = entity
           while let current = currentEntity {
               if current.name == "microphone_tex_v01" {
                   updateMicrophoneVisuals(current, isRecording: !isRecording)
                   toggleRecording()
                   if isRecording {
                        startNewPanel()
                    } else {
                        finalizePanel()
                    }
                   break
               }
               currentEntity = current.parent
           }
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

struct EmissiveMaterialComponent: Component {}
