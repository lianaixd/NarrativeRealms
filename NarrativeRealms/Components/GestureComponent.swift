//
//  GestureComponent.swift
//  NarrativeRealms
//
//  Created by Marc O'Cleirigh on 11/17/24.
//

// GestureComponent.swift
import RealityKit

public struct GestureComponent: Component, Codable {
    // Required by Component protocol
    public static var componentName = "GestureComponent"
    
    /// A Boolean value that indicates whether a gesture can drag the entity.
    public var canDrag: Bool = true
    
    /// Whether the drag gesture should pivot around the user
    public var pivotOnDrag: Bool = false
    
    /// Whether to preserve orientation during pivot drag
    public var preserveOrientationOnPivotDrag: Bool = true
}
