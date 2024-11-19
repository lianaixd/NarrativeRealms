//
//  CustomDragComponent.swift
//  NarrativeRealms
//
//  Created by Marc O'Cleirigh on 11/17/24.
//

import RealityKit
import SwiftUI

class CustomDragComponent: Component {
    var isDragging = false
    var initialPosition: SIMD3<Float>?
    var dragOffset: SIMD3<Float>?
    
    // Required by Component protocol
    static let componentName = "CustomDragComponent"
}
