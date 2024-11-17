//
//  GestureComponent.swift
//  NarrativeRealms
//
//  Created by Marc O'Cleirigh on 11/17/24.
//

// GestureComponent.swift
import RealityKit

public struct GestureComponent: Component, Codable {
    public static var componentName = "GestureComponent"
    
    public var canDrag: Bool = true
    public var pivotOnDrag: Bool = false
    public var preserveOrientationOnPivotDrag: Bool = true
    
    // Add snap-related properties
    public var isSnappable: Bool = true
    public var isSnapped: Bool = false
    public var snapRadius: Float = 0.3  // Adjust this value based on your needs
}
