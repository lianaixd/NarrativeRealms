import Combine
import RealityKit
import RealityKitContent
import SwiftUI

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
    
    private func exploreScene() {
        guard let scene = sceneEntity else { return }
            
        print("🔍 Scene Hierarchy:")
        printEntityDetails(scene, depth: 0)
    }
        
    private func printEntityDetails(_ entity: Entity, depth: Int) {
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)📦 Entity: \(entity.name)")
            
        // Print component information
        if let modelEntity = entity as? ModelEntity {
            print("\(indent)   - Type: ModelEntity")
            print("\(indent)   - Is Enabled: \(modelEntity.isEnabled)")
            print("\(indent)   - Has Collision: \(modelEntity.collision != nil)")
            print("\(indent)   - Position: \(modelEntity.position)")
        }
            
        // Recursively print children
        for child in entity.children {
            printEntityDetails(child, depth: depth + 1)
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
    private let allModelNames = [
        "_010_table_tex_v01",
        "storypath_tex_v01",
        "signpost_forest_tex_v01",
        "cottage_teapot_tex_v01",
        "lightbulb_tex_v01",
        "treasure_tex_v01",
        "signopost_snow_tex_v01",
        "dragon_anim_v03",
        "signpost_desert_tex_v01",
        "microphone_tex_v01",
        "Indicator8",
        "Indicator14",
        "Indicator17",
        "Indicator21",
        "Indicator24"
    ]
    
    var body: some View {
        RealityView { content in
            if let scene = sceneEntity {
                content.add(scene)
                handleInitialState(scene: scene)
            }
        }
        update: { content in
            // This is where we can access scene-level features
            if let scene = content.entities.first {
                // Setup collision subscriptions
                content.subscribe(to: CollisionEvents.Began.self) { event in
                    if let (draggable, indicator) = identifyDraggableAndIndicator(event.entityA, event.entityB) {
                        handleSnapToIndicator(draggable: draggable, indicator: indicator)
                    }
                }
                        
                content.subscribe(to: CollisionEvents.Ended.self) { event in
                    if let (draggable, _) = identifyDraggableAndIndicator(event.entityA, event.entityB) {
                        handleUnsnap(draggable: draggable)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            setupNotifications()
            loadFantasyScene()
        }
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                handleDrag(value: value)
            }
            .onEnded { value in
                handleDragEnd(value: value)
            })
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleEntityTap(value.entity)
                }
        )
    }
    
    private func handleInitialState(scene: Entity) {
           let modelsToHide = [
               "_010_table_tex_v01",
               "storypath_tex_v01",
               "signpost_forest_tex_v01",
               "cottage_teapot_tex_v01",
               "lightbulb_tex_v01",
               "treasure_tex_v01",
               "signopost_snow_tex_v01",
               "dragon_anim_v03",
               "signpost_desert_tex_v01",
               "microphone_tex_v01",
               "Indicator8", // First one
               "Indicator14", // Third (oh god liana why)
               "Indicator17", // Fifth
               "Indicator21", // Second
               "Indicator24" // Fourth
           ]
           
           NotificationCenter.default.post(
               name: .hideModels,
               object: nil,
               userInfo: ["modelNames": modelsToHide]
           )
       }
    
    private func findEntity(named: String, in entity: Entity) -> Entity? {
        if entity.name == named {
            return entity
        }
        for child in entity.children {
            if let found = findEntity(named: named, in: child) {
                return found
            }
        }
        return nil
    }
    
    private func setupNotifications() {
          // Add observers for model visibility notifications
          NotificationCenter.default.addObserver(
              forName: .showModel,
              object: nil,
              queue: .main
          ) { notification in
              if let modelName = notification.userInfo?["modelName"] as? String,
                 let scene = sceneEntity {
                  findEntity(named: modelName, in: scene)?.isEnabled = true
              }
          }

          NotificationCenter.default.addObserver(
              forName: .hideModel,
              object: nil,
              queue: .main
          ) { notification in
              if let modelName = notification.userInfo?["modelName"] as? String,
                 let scene = sceneEntity {
                  findEntity(named: modelName, in: scene)?.isEnabled = false
              }
          }

        NotificationCenter.default.addObserver(
               forName: .showModels,
               object: nil,
               queue: .main
           ) { notification in
               if let modelsToShow = notification.userInfo?["modelNames"] as? [String],
                  let scene = sceneEntity {
                   print("🎭 Showing only models: \(modelsToShow)")
                   
                   // First, hide all models
                   allModelNames.forEach { modelName in
                       if let entity = findEntity(named: modelName, in: scene) {
                           entity.isEnabled = false
                       }
                   }
                   
                   // Then, show only the specified models
                   modelsToShow.forEach { modelName in
                       if let entity = findEntity(named: modelName, in: scene) {
                           entity.isEnabled = true
                       }
                   }
               }
           }

          NotificationCenter.default.addObserver(
              forName: .hideModels,
              object: nil,
              queue: .main
          ) { notification in
              if let modelNames = notification.userInfo?["modelNames"] as? [String],
                 let scene = sceneEntity {
                  modelNames.forEach { modelName in
                      findEntity(named: modelName, in: scene)?.isEnabled = false
                  }
              }
          }
      }

    private func handleEntityTap(_ entity: Entity) {
        print("🔹 Tap detected on entity: \(entity.name)")
        
        // handle microphone tap
        if let scene = sceneEntity,
               let microphoneEntity = findEntity(named: "MicrophoneInteractive", in: scene) {
                // Check if tapped entity is the microphone or its descendant
                if entity == microphoneEntity || entity.parent?.id == microphoneEntity.id {
                    toggleRecording()
                    if isRecording {
                        startNewPanel()
                    } else {
                        finalizePanel()
                    }
                }
            }
    
        if let scene = sceneEntity,
               let lightbulbEntity = findEntity(named: "LightbulbInteractive", in: scene) {
                // Check if tapped entity is the lightbulb or its descendant
                if entity == lightbulbEntity || entity.parent?.id == lightbulbEntity.id {
                    handleLightbulbTap()
                }
            }
    }
    
    private func handleLightbulbTap() {
        // Handle lightbulb tap based on current tutorial step
        switch tutorialStep {
        case 22:
            print("✨ Lightbulb tapped in step 22, advancing to step 23")
            tutorialStep = 23
        case 25:
            print("✨ Lightbulb tapped in step 25, advancing to step 26")
            tutorialStep = 26
        default:
            print("✨ Lightbulb tapped in step \(tutorialStep) - no action needed")
            break
        }
    }

    private func toggleRecording() {
        isRecording.toggle()
        print("🎤 \(isRecording ? "Started" : "Stopped") recording")
            
        if isRecording {
            try? recordingManager.startRecording()
        } else {
            recordingManager.stopRecording()
                // Handle microphone recording based on current tutorial step
                switch tutorialStep {
                case 12:
                    print("✨ Microphone used in step 12, advancing to step 13")
                    tutorialStep = 13
                case 19:
                    print("✨ Microphone used in step 25, advancing to step 26")
                    tutorialStep = 20
                default:
                    print("✨ Microphone used in step \(tutorialStep) - no action needed")
                    break
                }

        }
    }
    
    private func loadFantasyScene() {
        Task {
            do {
                let scene = try await Entity.load(named: "FantasyScene", in: realityKitContentBundle)
                sceneEntity = scene
                    
                // Find and setup the draggable entity
                if let draggableEntity = findEntity(named: "TestAnimation", in: scene) {
                    setupGestures(for: draggableEntity)
                }
                    
                // Find and setup all indicators
                let indicatorNames = ["Indicator8", "Indicator14", "Indicator17", "Indicator21", "Indicator24"]
                for name in indicatorNames {
                    if let indicator = findEntity(named: name, in: scene) {
                        EntityGestureState.shared.indicators.append(indicator)
                        setupIndicator(indicator)
                    }
                }
                
                print("✅ FantasyScene loaded successfully.")
            } catch {
                print("❌ Error loading FantasyScene: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleDrag(value: EntityTargetValue<DragGesture.Value>) {
        let entity = value.entity
        guard let gestureComponent = entity.components[GestureComponent.self],
              gestureComponent.canDrag else { return }
           
        let state = EntityGestureState.shared
           
        // First time initialization
        if state.targetedEntity == nil {
            state.targetedEntity = entity
            state.dragStartPosition = entity.position
            state.isDragging = true
            state.initialOrientation = entity.orientation(relativeTo: nil)
        }
           
        guard state.isDragging else { return }
           
        // Calculate new position
        let translation = value.gestureValue.translation3D
        let dampening: Float = 0.001 // Reduce this value to slow down movement (0.01 = 1%, 0.001 = 0.1%)

        let newPosition = state.dragStartPosition + SIMD3<Float>(
            Float(translation.x) * dampening,
            -Float(translation.y) * dampening,
            Float(translation.z) * dampening
        )
           
        // Check for snapping
        if let (shouldSnap, snapPosition, indicator) = checkForSnapping(entity: entity, currentPosition: newPosition) {
            if shouldSnap {
                entity.position = snapPosition
                state.currentSnappedIndicator = indicator
                if var gestureComp = entity.components[GestureComponent.self] {
                    gestureComp.isSnapped = true
                    entity.components[GestureComponent.self] = gestureComp
                }
                return
            }
        }
           
        // If we're not snapping, update position normally
        entity.position = newPosition
        state.currentSnappedIndicator = nil
        if var gestureComp = entity.components[GestureComponent.self] {
            gestureComp.isSnapped = false
            entity.components[GestureComponent.self] = gestureComp
        }
    }
    
    private func checkForSnapping(entity: Entity, currentPosition: SIMD3<Float>) -> (shouldSnap: Bool, position: SIMD3<Float>, indicator: Entity)? {
        guard let gestureComponent = entity.components[GestureComponent.self],
              gestureComponent.isSnappable else { return nil }
           
        let state = EntityGestureState.shared
           
        for indicator in state.indicators {
            let indicatorPosition = indicator.position
               
            // Calculate distance between entity and indicator
            let distance = length(currentPosition - indicatorPosition)
               
            // If within snap radius, snap to indicator position
            if distance < gestureComponent.snapRadius {
                return (true, indicatorPosition, indicator)
            }
        }
           
        return nil
    }
        
    private func handleDragEnd(value: EntityTargetValue<DragGesture.Value>) {
        let state = EntityGestureState.shared
            
        // If we ended on a snap point, make sure we're exactly on it
        if let snapIndicator = state.currentSnappedIndicator,
           let entity = state.targetedEntity
        {
            entity.position = snapIndicator.position
        }
            
        state.targetedEntity = nil
        state.isDragging = false
        state.initialOrientation = nil
    }
    
    private func setupGestures(for entity: Entity) {
        // Setup gesture component
        var gestureComponent = GestureComponent()
        gestureComponent.canDrag = true
        entity.components[GestureComponent.self] = gestureComponent
        
        // Add collision component
        let bounds = entity.visualBounds(recursive: true, relativeTo: nil)
        let size = SIMD3<Float>(
            bounds.max.x - bounds.min.x,
            bounds.max.y - bounds.min.y,
            bounds.max.z - bounds.min.z
        )
        
        // Make collision shape slightly larger for better interaction
        let padding: Float = 0.2
        let interactionSize = size + SIMD3<Float>(padding, padding, padding)
        
        // Create collision component with proper shapes
        let collisionShape = ShapeResource.generateBox(size: interactionSize)
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [collisionShape],
            mode: .default,
            filter: .init(group: .default, mask: .all)
        )
        
        // Add input target component
        var inputTarget = InputTargetComponent()
        inputTarget.allowedInputTypes = .all
        inputTarget.isEnabled = true
        entity.components[InputTargetComponent.self] = inputTarget
    }
    
    private func setupIndicator(_ entity: Entity) {
        // Setup indicator as a trigger volume
        let indicatorBounds = entity.visualBounds(recursive: true, relativeTo: nil)
        let indicatorSize = SIMD3<Float>(
            indicatorBounds.max.x - indicatorBounds.min.x,
            indicatorBounds.max.y - indicatorBounds.min.y,
            indicatorBounds.max.z - indicatorBounds.min.z
        )
        
        // Make trigger volume slightly larger than visual bounds
        let padding: Float = 0.2
        let triggerSize = indicatorSize + SIMD3<Float>(padding, padding, padding)
        
        let triggerShape = ShapeResource.generateBox(size: triggerSize)
        entity.components[CollisionComponent.self] = CollisionComponent(
            shapes: [triggerShape],
            mode: .trigger, // This makes it a trigger volume
            filter: .init(group: .default, mask: .all)
        )
    }

    private func identifyDraggableAndIndicator(_ entityA: Entity, _ entityB: Entity) -> (draggable: Entity, indicator: Entity)? {
        let state = EntityGestureState.shared
        
        if state.indicators.contains(entityA) && entityB.components[GestureComponent.self] != nil {
            return (entityB, entityA)
        } else if state.indicators.contains(entityB) && entityA.components[GestureComponent.self] != nil {
            return (entityA, entityB)
        }
        
        return nil
    }

    private func handleSnapToIndicator(draggable: Entity, indicator: Entity) {
        let state = EntityGestureState.shared
        state.currentSnappedIndicator = indicator
        
        // Snap to indicator position
        draggable.position = indicator.position
        
        if var gestureComp = draggable.components[GestureComponent.self] {
            gestureComp.isSnapped = true
            draggable.components[GestureComponent.self] = gestureComp
        }
    }

    private func handleUnsnap(draggable: Entity) {
        let state = EntityGestureState.shared
        state.currentSnappedIndicator = nil
        
        if var gestureComp = draggable.components[GestureComponent.self] {
            gestureComp.isSnapped = false
            draggable.components[GestureComponent.self] = gestureComp
        }
    }
}

// Add notification name
extension Notification.Name {
    static let createTranscriptionWindow = Notification.Name("createTranscriptionWindow")
    static let showModel = Notification.Name("showModel")
    static let hideModel = Notification.Name("hideModel")
    static let showModels = Notification.Name("showModels")
    static let hideModels = Notification.Name("hideModels")
}

// Helper extension to print entity hierarchy
extension Entity {
    func printEntityHierarchy(depth: Int = 0) {
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)📦 Entity: \(name)")
        for child in children {
            child.printEntityHierarchy(depth: depth + 1)
        }
    }
}

struct EmissiveMaterialComponent: Component {}
