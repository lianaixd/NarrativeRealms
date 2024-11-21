import Combine
import RealityKit
import RealityKitContent
import SwiftUI

struct TranscriptionPanel: Component {
    var text: String
}

extension ImmersiveView {
    private func createTextPanel(withText text: String) -> ModelEntity {
           // Reduce panel size
           let panel = ModelEntity(
               mesh: .generatePlane(width: 0.2, height: 0.15),  // Reduced from 0.3, 0.2
               materials: [SimpleMaterial(color: .white.withAlphaComponent(0.8), isMetallic: false)]
           )
           
           updateTextInPanel(panel: panel, text: text)
           panel.components[TranscriptionPanel.self] = TranscriptionPanel(text: text)
           
           return panel
       }
    
    private func updateTextInPanel(panel: ModelEntity, text: String) {
        print("updateTextInPanel")
            panel.children.forEach { $0.removeFromParent() }
            
            let textEntity = ModelEntity()
            let textMesh = MeshResource.generateText(
                text.isEmpty ? "Start speaking to record..." : text,
                extrusionDepth: 0.001,
                font: .systemFont(ofSize: 0.015),  // Reduced from 0.02
                containerFrame: CGRect(x: -0.09, y: -0.06, width: 0.18, height: 0.12),  // Adjusted proportionally
                alignment: .left,
                lineBreakMode: .byWordWrapping
            )
            textEntity.model = ModelComponent(mesh: textMesh, materials: [SimpleMaterial(color: .black, isMetallic: false)])
            panel.addChild(textEntity)
        }
    
    private func positionPanelAboveIndicator(panel: ModelEntity, indicator: Entity?) {
        print("positionPanelAboveIndicator")
            guard let indicator = indicator ?? EntityGestureState.shared.currentSnappedIndicator else {
                print("positionPanelAboveIndicator -> no indicator, placing in default position")
                // Default position if no indicator
                panel.position = SIMD3<Float>(0.3, 1.5, -1.0)
                return
            }
            
            // Initialize PanelInfo for this indicator if it doesn't exist
            if storyPanels[indicator] == nil {
                print("positionPanelAboveIndicator -> initializing panel indicator")
                storyPanels[indicator] = PanelInfo()
            }
            
            // Get the indicator's world position
            let indicatorPosition = indicator.position(relativeTo: nil)
        print("positionPanelAboveIndicator -> indicatorPosition: \(indicatorPosition)")
            // Calculate vertical offset based on existing panels
            var panelInfo = storyPanels[indicator]!
            let verticalOffset = panelInfo.nextPosition
            
            // Position the panel above the indicator
            panel.position = SIMD3<Float>(
                indicatorPosition.x,
                indicatorPosition.y + verticalOffset,
                indicatorPosition.z - 0.1  // Slight offset forward
            )
            
            // Update tracking
            panelInfo.panels.append(panel)
            panelInfo.nextPosition += 0.2  // Increment for next panel
            storyPanels[indicator] = panelInfo
        }
    
    private func startNewPanel() {
        print("startNewPanel")
            guard let scene = sceneEntity else { return }
            
            // Create a new panel with a default message
            let panel = createTextPanel(withText: "Start speaking to record...")
            
            // Position above current indicator if one exists
            positionPanelAboveIndicator(panel: panel, indicator: nil)
            
            scene.addChild(panel)
            currentPanel = panel
            
            // Reset the transcribed text
            recordingManager.transcribedText = ""
            
            cancellable = recordingManager.$transcribedText
                .receive(on: RunLoop.main)
                .sink { text in
                    if let panel = currentPanel {
                        updateTextInPanel(panel: panel, text: text)
                    }
                }
        }
    
    private func finalizePanel() {
        print("🎬 Finalizing panel")
        cancellable?.cancel()
        
        if let panel = currentPanel {
            // First try getting the indicator from EntityGestureState
            var indicator = EntityGestureState.shared.currentSnappedIndicator
            
            if indicator == nil {
                print("🔍 Trying to find current indicator manually")
                indicator = getCurrentSnappedIndicator()
            }
            
            if let foundIndicator = indicator {
                print("📌 Positioning panel above indicator: \(foundIndicator.name)")
                positionPanelAboveIndicator(panel: panel, indicator: foundIndicator)
            } else {
                print("⚠️ No indicator found - using default position")
                // Use a default position if no indicator is found
                panel.position = SIMD3<Float>(0.3, 1.5, -1.0)
            }
            
            currentPanel = nil
        } else {
            print("⚠️ No current panel to finalize")
        }
    }
    
    // Add this to your ImmersiveView extension
    private func getCurrentSnappedIndicator() -> Entity? {
        guard let scene = sceneEntity,
              let tag = findEntity(named: "TestAnimation", in: scene) else {
            print("⚠️ Could not find Tag entity")
            return nil
        }

        // Get Tag's current position
        let tagPosition = tag.position(relativeTo: nil)
        print("📍 Tag position: \(tagPosition)")

        // Check if Tag has a gesture component and is snapped
        guard let gestureComp = tag.components[GestureComponent.self],
              gestureComp.isSnapped else {
            print("⚠️ Tag is not currently snapped")
            return nil
        }

        // Find the closest enabled indicator
        let state = EntityGestureState.shared
        var closestIndicator: Entity?
        var closestDistance: Float = .infinity

        for indicator in state.indicators where indicator.isEnabled {
            // Get the CollisionVolume child
            guard let collisionVolume = indicator.children.first(where: { $0.name.contains("CollisionVolume") }) else {
                continue
            }

            let indicatorPosition = collisionVolume.position(relativeTo: nil)
            let distance = length(tagPosition - indicatorPosition)

            if distance < closestDistance {
                closestDistance = distance
                closestIndicator = indicator
            }
        }

        if let indicator = closestIndicator {
            print("✅ Found snapped indicator: \(indicator.name)")
        } else {
            print("⚠️ No close indicator found")
        }

        return closestIndicator
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
        "TestAnimation",
        "storypath_tex_v01",
        "signpost_forest_tex_v01",
        "cottage_teapot_tex_v01",
        "lightbulb_tex_v01",
        "treasure_tex_v01",
        "signopost_snow_tex_v01",
        "dragon_anim_v03",
        "signpost_desert_tex_v01",
        "microphone_tex_v01",
        "StorylineStep1",
        "StorylineStep2",
        "StorylineStep3",
        "StorylineStep4",
        "StorylineStep5"
    ]
    // Track panels associated with each indicator
    private struct PanelInfo {
        var panels: [ModelEntity] = []
        var nextPosition: Float = 0.2  // Initial height offset
    }
    
    @State private var storyPanels: [Entity: PanelInfo] = [:]
    
    private var tagAnimationController: AnimationManager? {
            guard let scene = sceneEntity,
                  let tagEntity = findEntity(named: "TestAnimation", in: scene) else {
                return nil
            }
            return AnimationManager(entity: tagEntity)
        }
    private var dragonAnimationController: AnimationManager? {
            guard let scene = sceneEntity,
                  let dragonEntity = findEntity(named: "dragon_anim_v03", in: scene) else {
                return nil
            }
            return AnimationManager(entity: dragonEntity)
        }
    
    var body: some View {
        RealityView { content in
            if let scene = sceneEntity {
                content.add(scene)
                handleInitialState(scene: scene)
            }
        }
        update: { content in
            if let scene = content.entities.first {
                // Setup collision subscriptions
                content.subscribe(to: CollisionEvents.Began.self) { event in
                    print("💥 Collision began between \(event.entityA.name) and \(event.entityB.name)")
                    if let (draggable, indicator) = identifyDraggableAndIndicator(event.entityA, event.entityB) {
                        // Only handle collision if both entities are enabled
                        guard draggable.isEnabled && indicator.isEnabled else {
                            print("⚠️ Skipping collision - one or both entities disabled")
                            return
                        }
                        handleSnapToIndicator(draggable: draggable, indicator: indicator)
                        
                        print("📢 Posting tagSnappedToIndicator notification for indicator: \(indicator.name)")
                                       NotificationCenter.default.post(
                                           name: .tagSnappedToIndicator,
                                           object: nil,
                                           userInfo: ["indicator": indicator.name]
                                       )
                    }
                }
                                       
                content.subscribe(to: CollisionEvents.Ended.self) { event in
                    print("💨 Collision ended between \(event.entityA.name) and \(event.entityB.name)")
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
            "StorylineStep1",
            "StorylineStep2",
            "StorylineStep3",
            "StorylineStep4",
            "StorylineStep5"
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
               let scene = sceneEntity
            {
                findEntity(named: modelName, in: scene)?.isEnabled = true
                handleModelVisibility(modelName: modelName, isVisible: true)
            }
        }

        NotificationCenter.default.addObserver(
            forName: .hideModel,
            object: nil,
            queue: .main
        ) { notification in
            if let modelName = notification.userInfo?["modelName"] as? String,
               let scene = sceneEntity
            {
                findEntity(named: modelName, in: scene)?.isEnabled = false
                handleModelVisibility(modelName: modelName, isVisible: false)
            }
        }

        NotificationCenter.default.addObserver(
            forName: .showModels,
            object: nil,
            queue: .main
        ) { notification in
            if let modelsToShow = notification.userInfo?["modelNames"] as? [String],
               let scene = sceneEntity
            {
                print("🎭 Showing only models: \(modelsToShow)")
                // Then, show only the specified models
                for modelName in modelsToShow {
                    if let entity = findEntity(named: modelName, in: scene) {
                        entity.isEnabled = true
                        handleModelVisibility(modelName: modelName, isVisible: true)
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
               let scene = sceneEntity
            {
                for modelName in modelNames {
                    findEntity(named: modelName, in: scene)?.isEnabled = false
                }
            }
        }
        
        NotificationCenter.default.addObserver(
                forName: .playAnimation,
                object: nil,
                queue: .main
            ) { notification in
                if let entityName = notification.userInfo?["entityName"] as? String,
                   let animationName = notification.userInfo?["animationName"] as? String,
                   let scene = sceneEntity,
                   let entity = findEntity(named: entityName, in: scene) {
                    print("🎭 Playing animation for model: \(entityName)")
                    playAnimation(for: entity, animationName: animationName)
                }
            }
    }

    private func handleEntityTap(_ entity: Entity) {
        print("🔹 Tap detected on entity: \(entity.name)")
        
        // handle microphone tap
        if let scene = sceneEntity,
           let microphoneEntity = findEntity(named: "MicrophoneInteractive", in: scene)
        {
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
           let lightbulbEntity = findEntity(named: "LightbulbInteractive", in: scene)
        {
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
                let indicatorNames = ["StorylineStep1",
                                      "StorylineStep2",
                                      "StorylineStep3",
                                      "StorylineStep4",
                                      "StorylineStep5"]
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
              gestureComponent.canDrag
        else {
            print("❌ Drag rejected - no gesture component or can't drag")
            return
        }
           
        let state = EntityGestureState.shared
           
        // First time initialization
        if state.targetedEntity == nil {
            print("🎯 Starting new drag for entity: \(entity.name)")
            state.targetedEntity = entity
            state.dragStartPosition = entity.position
            state.isDragging = true
            state.initialOrientation = entity.orientation(relativeTo: nil)
            print("📍 Start position: \(state.dragStartPosition)")
        }
           
        guard state.isDragging else {
            print("❌ Not in dragging state")
            return
        }
           
        // Calculate new position
        let translation = value.gestureValue.translation3D
        let dampening: Float = 0.002 // Reduce this value to slow down movement (0.01 = 1%, 0.001 = 0.1%)

        let newPosition = state.dragStartPosition + SIMD3<Float>(
            Float(translation.x) * dampening,
            -Float(translation.y) * dampening,
            Float(translation.z) * dampening
        )
        
        // print("🔄 Calculated new position: \(newPosition)")
           
        // Check for snapping
        if let (shouldSnap, snapPosition, indicator) = checkForSnapping(entity: entity, currentPosition: newPosition) {
            if shouldSnap {
                print("🔒 Snapping to indicator: \(indicator.name)")
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
        // print("📱 Setting position to: \(newPosition)")
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
        let snapRadius = gestureComponent.snapRadius
        let breakRadius = snapRadius * 2.0
               
        for indicator in state.indicators {
            // Skip disabled indicators
            guard indicator.isEnabled else { continue }
            
            // Get the CollisionVolume child
            guard let collisionVolume = indicator.children.first(where: { $0.name.contains("CollisionVolume") }) else {
                continue
            }
            
            let indicatorPosition = collisionVolume.position(relativeTo: nil) // Get world position
            let distance = length(currentPosition - indicatorPosition)
                   
            // If already snapped to this indicator, use break radius
            if state.currentSnappedIndicator == indicator {
                if distance > breakRadius {
                    return nil
                }
                return (true, indicatorPosition, indicator)
            }
            
            // For new snaps, use normal snap radius
            if distance < snapRadius {
                return (true, indicatorPosition, indicator)
            }
        }
               
        return nil
    }

    private func handleDragEnd(value: EntityTargetValue<DragGesture.Value>) {
        let state = EntityGestureState.shared
            
        print("🏁 Ending drag")

        if let entity = state.targetedEntity {
            // If we ended on a snap point, make sure we're exactly on it
            if let snapIndicator = state.currentSnappedIndicator {
                print("📍 Finalizing snap to: \(snapIndicator.name)")
                entity.position = snapIndicator.position
            } else {
                // Store the final position
                print("📍 Finalizing position at: \(entity.position)")
            }
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
        // Store the parent (StorylineStep) entity as the indicator
        print("🎯 Setting up indicator: \(entity.name)")
        EntityGestureState.shared.indicators.append(entity)
        
        // Verify collision setup on the child
        if let collisionVolume = entity.children.first(where: { $0.name.contains("CollisionVolume") }) {
            if let collision = collisionVolume.components[CollisionComponent.self] {
                if collision.mode != .trigger {
                    print("⚠️ Warning: Collision volume for \(entity.name) is not in trigger mode")
                }
            } else {
                print("❌ Error: Collision volume for \(entity.name) is missing CollisionComponent")
            }
        } else {
            print("❌ Error: \(entity.name) is missing CollisionVolume child entity")
        }
    }
    
    private func identifyDraggableAndIndicator(_ entityA: Entity, _ entityB: Entity) -> (draggable: Entity, indicator: Entity)? {
        let state = EntityGestureState.shared
        
        // Function to check if an entity is or belongs to an indicator
        func findIndicator(_ entity: Entity) -> Entity? {
            // Check if this entity is an indicator
            if state.indicators.contains(entity) {
                return entity
            }
            // Check if this entity is a CollisionVolume of an indicator
            if let parent = entity.parent, state.indicators.contains(parent) {
                return parent
            }
            return nil
        }
        
        // Check for gesture component
        let hasAGesture = entityA.components[GestureComponent.self] != nil
        let hasBGesture = entityB.components[GestureComponent.self] != nil
        
        // Find indicators
        let indicatorA = findIndicator(entityA)
        let indicatorB = findIndicator(entityB)
        
        if let indicator = indicatorA, hasBGesture {
            return (entityB, indicator)
        } else if let indicator = indicatorB, hasAGesture {
            return (entityA, indicator)
        }
        
        return nil
    }

    private func handleSnapToIndicator(draggable: Entity, indicator: Entity) {
        let state = EntityGestureState.shared
        
        // Don't re-snap if already snapped to this indicator
        guard state.currentSnappedIndicator != indicator else {
            print("⏭️ Already snapped to this indicator, skipping")
            return
        }
        
        print("🔒 Snapping \(draggable.name) to \(indicator.name)")
        state.currentSnappedIndicator = indicator
        
        // Store world position before changing
        let targetPosition = indicator.position(relativeTo: nil)
        print("📍 Moving to position: \(targetPosition)")
        
        draggable.setPosition(targetPosition, relativeTo: nil)
        
        if var gestureComp = draggable.components[GestureComponent.self] {
            gestureComp.isSnapped = true
            draggable.components[GestureComponent.self] = gestureComp
            print("✅ Updated gesture component isSnapped to true")
        }
    }

    private func handleUnsnap(draggable: Entity) {
        print("handleSnapToIndicator")
        let state = EntityGestureState.shared
        state.currentSnappedIndicator = nil
        
        if var gestureComp = draggable.components[GestureComponent.self] {
            gestureComp.isSnapped = false
            draggable.components[GestureComponent.self] = gestureComp
        }
    }
    
    private func handleIndicatorVisibilityChange(indicator: Entity, isVisible: Bool) {
        let state = EntityGestureState.shared
        
        if !isVisible && state.currentSnappedIndicator == indicator {
            // If we're hiding an indicator that has something snapped to it
            if let snappedEntity = state.targetedEntity {
                // Store the current world position before unsnapping
                let currentWorldPosition = snappedEntity.position(relativeTo: nil)
                
                // Clear snap state
                state.currentSnappedIndicator = nil
                if var gestureComp = snappedEntity.components[GestureComponent.self] {
                    gestureComp.isSnapped = false
                    snappedEntity.components[GestureComponent.self] = gestureComp
                }
                
                // Maintain the entity's world position
                snappedEntity.setPosition(currentWorldPosition, relativeTo: nil)
            }
        }
    }

    private func handleModelVisibility(modelName: String, isVisible: Bool) {
        guard let scene = sceneEntity,
              let entity = findEntity(named: modelName, in: scene) else { return }
        
        let state = EntityGestureState.shared
        
        // If this is a StorylineStep entity
        if modelName.contains("StorylineStep") {
            // If we're hiding a StorylineStep and Tag is snapped to it
            if !isVisible && state.currentSnappedIndicator == entity {
                if let tag = findEntity(named: "TestAnimation", in: scene) {
                    print("📍 Preserving Tag position while unsnapping from \(modelName)")
                    
                    // Store current world position before any changes
                    let currentWorldPosition = tag.position(relativeTo: nil)
                    
                    // Clear snap state
                    state.currentSnappedIndicator = nil
                    if var gestureComp = tag.components[GestureComponent.self] {
                        gestureComp.isSnapped = false
                        tag.components[GestureComponent.self] = gestureComp
                    }
                    
                    // Force reset the state
                    state.reset()
                    
                    // Explicitly set position in world space
                    tag.setPosition(currentWorldPosition, relativeTo: nil)
                }
            }
        }
        
        // Set visibility after handling any unsnapping
        entity.isEnabled = isVisible
        
        // If becoming visible and it's the dragon, play its animation
               if isVisible && modelName == "dragon_anim_v03" {
                   playAnimation(for: entity, animationName: "Breath")
               }
        
        // Debug logging
        if modelName.contains("StorylineStep") {
            // print("🎭 \(isVisible ? "Showing" : "Hiding") \(modelName)")
            print("Current snap state - Indicator: \(state.currentSnappedIndicator?.name ?? "none")")
            if let tag = findEntity(named: "TestAnimation", in: scene) {
                print("Tag position: \(tag.position)")
            }
        }
    }
    
    private func resetTagPosition() {
        guard let scene = sceneEntity,
              let tag = findEntity(named: "Tag", in: scene) else { return }
        
        // Reset to a known good position
        let defaultPosition = SIMD3<Float>(0, 1.5, -1.0) // Adjust these coordinates
        tag.position = defaultPosition
        
        // Reset gesture state
        EntityGestureState.shared.reset()
        
        // Ensure components are in correct state
        if var gestureComp = tag.components[GestureComponent.self] {
            gestureComp.isSnapped = false
            tag.components[GestureComponent.self] = gestureComp
        }
    }
    
    // Function to play animation
    private func playAnimation(for entity: Entity, animationName: String) {
        let animations = entity.availableAnimations
        print("🎬 Looking for animations for \(entity.name)")
        
        if entity.name == "TestAnimation" {
            tagAnimationController?.playAnimation(named: animationName)
            print("▶️ Started Tag animation")
        } else if entity.name == "dragon_anim_v03" {
            dragonAnimationController?.playAnimation(named: animationName)
        } else {
            print("Animation was not for Tag or Dragon")
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
    static let playAnimation = Notification.Name("playAnimation")
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
