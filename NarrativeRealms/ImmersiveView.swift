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
                  
                // Update visibility based on tutorial step
                updateSceneForTutorialStep(scene: scene, step: tutorialStep)
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
            loadFantasyScene()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                exploreScene() // Give the scene time to load
            }
        }
        .onChange(of: tutorialStep) { _, newValue in
            // Update scene when tutorial step changes
            if let scene = sceneEntity {
                updateSceneForTutorialStep(scene: scene, step: newValue)
            }
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
    
    private func updateSceneForTutorialStep(scene: Entity, step: Int) {
        // Helper function to recursively find entities by name
        print("updateSceneForTutorialStep")
        
        // Example: Show/hide entities based on tutorial step
        switch step {
        case 1:
            print("updateSceneForTutorialStep: step 0")
            findEntity(named: "_010_table_tex_v01", in: scene)?.isEnabled = false
            findEntity(named: "storypath_tex_v01", in: scene)?.isEnabled = false
            findEntity(named: "signpost_forest_tex_v01", in: scene)?.isEnabled = false
            findEntity(named: "cottage_teapot_tex_v01", in: scene)?.isEnabled = false
            findEntity(named: "lightbulb_tex_v01", in: scene)?.isEnabled = false
            findEntity(named: "treasure_tex_v01", in: scene)?.isEnabled = false
            findEntity(named: "signopost_snow_tex_v01", in: scene)?.isEnabled = false
            findEntity(named: "dragon_anim_v03", in: scene)?.isEnabled = false
            findEntity(named: "signpost_desert_tex_v01", in: scene)?.isEnabled = false
            findEntity(named: "microphone_tex_v01", in: scene)?.isEnabled = false
        case 4:
            findEntity(named: "_010_table_tex_v01", in: scene)?.isEnabled = true
        case 6:
            findEntity(named: "storypath_tex_v01", in: scene)?.isEnabled = true
        case 10:
            findEntity(named: "microphone_tex_v01", in: scene)?.isEnabled = true
        case 13:
            findEntity(named: "signpost_forest_tex_v01", in: scene)?.isEnabled = true
        case 17:
            findEntity(named: "dragon_anim_v03", in: scene)?.isEnabled = true
        case 20:
            findEntity(named: "cottage_teapot_tex_v01", in: scene)?.isEnabled = true
        case 22:
            findEntity(named: "lightbulb_tex_v01", in: scene)?.isEnabled = true
            if let lightbulb = findEntity(named: "lightbulb_tex_v01", in: scene) as? ModelEntity {
                            makeEntityInteractive(lightbulb)
                        }
        case 23:
            findEntity(named: "treasure_tex_v01", in: scene)?.isEnabled = true
        case 24:
            findEntity(named: "signopost_snow_tex_v01", in: scene)?.isEnabled = true
        case 27:
            findEntity(named: "signpost_desert_tex_v01", in: scene)?.isEnabled = true
        default:
            // Final state or reset state
            break
        }
    }
    
    private func makeAllMicrophonePartsInteractive(_ groupEntity: Entity) {
        print("🎯 Setting up microphone interaction. Entity type: \(type(of: groupEntity))")
        
        // Calculate the overall bounds of the microphone group
        let bounds = groupEntity.visualBounds(relativeTo: groupEntity)
        
        // Create a slightly larger invisible collision box
        let padding: Float = 0.05 // Adjust this value to make the hit box bigger
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
            max(0.001, bounds.max.x - bounds.min.x), // Ensure non-zero size
            max(0.001, bounds.max.y - bounds.min.y),
            max(0.001, bounds.max.z - bounds.min.z)
        ])
        entity.collision = CollisionComponent(shapes: [boxShape])
        entity.components.set(InputTargetComponent())
    }

    private func handleEntityTap(_ entity: Entity) {
        print("🔹 Tap detected on entity: \(entity.name)")
        printEntityDetails(entity, depth: 0) // Print details of tapped entity
        
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
        
        // Now check for lightbulb tap
                currentEntity = entity
                while let current = currentEntity {
                    if current.name == "lightbulb_tex_v01" {
                        handleLightbulbTap()
                        break
                    }
                    currentEntity = current.parent
                }
    }
    
    private func handleLightbulbTap() {
           // Handle lightbulb tap based on current tutorial step
           switch tutorialStep {
           case 22:
               // Move to next step when lightbulb is tapped in step 22
               tutorialStep = 23
           case 25:
               // Move to next step when lightbulb is tapped in step 25
               tutorialStep = 26
           default:
               break
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
            let dampening: Float = 0.001  // Reduce this value to slow down movement (0.01 = 1%, 0.001 = 0.1%)

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
               let entity = state.targetedEntity {
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
            mode: .trigger,  // This makes it a trigger volume
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
