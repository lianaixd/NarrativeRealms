//
//  GestureStateComponent.swift
//  NarrativeRealms
//
//  Created by Marc O'Cleirigh on 11/17/24.
//
import RealityKit

class GestureStateComponent: Component {
    var targetedEntity: Entity?
    var initialPosition: SIMD3<Float>?
    var dragOffset: SIMD3<Float>?
    var isDragging: Bool = false
    
    static let componentName = "GestureStateComponent"
}
