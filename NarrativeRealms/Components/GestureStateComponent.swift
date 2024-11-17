//
//  GestureStateComponent.swift
//  NarrativeRealms
//
//  Created by Marc O'Cleirigh on 11/17/24.
//
import RealityKit

class GestureStateComponent {
    var targetedEntity: Entity?
    var dragStartPosition: SIMD3<Float> = .zero
    var isDragging = false
    var pivotEntity: Entity?
    var initialOrientation: simd_quatf?

    // Add indicator tracking
    var indicators: [Entity] = []
    var currentSnappedIndicator: Entity?

    static let shared = GestureStateComponent()
    private init() {}
}
