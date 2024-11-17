//
//  GestureStateComponent.swift
//  NarrativeRealms
//
//  Created by Marc O'Cleirigh on 11/17/24.
//
import RealityKit

class GestureStateComponent {
    /// The entity currently being dragged if a gesture is in progress
    var targetedEntity: Entity?
    
    /// The starting position
    var dragStartPosition: SIMD3<Float> = .zero
    
    /// Marks whether the app is currently handling a drag gesture
    var isDragging = false
    
    /// When rotateOnDrag is true, this entity acts as the pivot point for the drag
    var pivotEntity: Entity?
    
    var initialOrientation: simd_quatf?
    
    /// Singleton accessor
    static let shared = GestureStateComponent()
    
    private init() {}
}
