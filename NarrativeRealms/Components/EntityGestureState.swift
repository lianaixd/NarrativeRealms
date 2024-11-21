//
//  EntityGestureState.swift
//  NarrativeRealms
//
//  Created by Marc O'Cleirigh on 11/17/24.
//
import RealityKit

class EntityGestureState {
    var lastSnappedPosition: SIMD3<Float>?
    var targetedEntity: Entity? {
        didSet {
            if targetedEntity == nil {
                // Reset other state when entity becomes nil
                isDragging = false
                currentSnappedIndicator = nil
                initialOrientation = nil
            }
        }
    }

    var dragStartPosition: SIMD3<Float> = .zero
    var isDragging = false {
        didSet {
            if !isDragging {
                // Reset snap state when not dragging
                currentSnappedIndicator = nil
            }
        }
    }

    var pivotEntity: Entity?
    var initialOrientation: simd_quatf?

    // Add indicator tracking
    var indicators: [Entity] = []
    var currentSnappedIndicator: Entity?

    static let shared = EntityGestureState()
    private init() {}
    
    func snapTo(indicator: Entity) {
        currentSnappedIndicator = indicator
        lastSnappedPosition = indicator.position(relativeTo: nil)
    }
       
    func unsnap() {
        currentSnappedIndicator = nil
        lastSnappedPosition = nil
    }
    
    func reset() {
        if let targetedEntity = targetedEntity,
           let gestureComp = targetedEntity.components[GestureComponent.self]
        {
            var updatedComp = gestureComp
            updatedComp.isSnapped = false
            targetedEntity.components[GestureComponent.self] = updatedComp
                
            // If we have a last known good position, use it
            if let lastPos = lastSnappedPosition {
                targetedEntity.setPosition(lastPos, relativeTo: nil)
            }
        }
            
        targetedEntity = nil
        dragStartPosition = .zero
        isDragging = false
        currentSnappedIndicator = nil
        initialOrientation = nil
        lastSnappedPosition = nil
    }
}
