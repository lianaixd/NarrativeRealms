//
//  ModelVisibilityManager.swift
//  NarrativeRealms
//
//  Created by Marc O'Cleirigh on 11/20/24.
//

import SwiftUI

/// Manages the visibility state of models in the scene, ensuring efficient updates and preventing redundant show/hide operations
class ModelVisibilityManager: ObservableObject {
    static let shared = ModelVisibilityManager()
    
    // Track current visible models
    private var visibleModels: Set<String> = []
    
    // Function to update visibility state
    func updateVisibility(models: [String]) {
        let sceneModelSet = Set(models)
        
        // Find models that need to be hidden
        let modelsToHide = visibleModels.subtracting(sceneModelSet)
        if !modelsToHide.isEmpty {
            print("🔴 Hiding models: \(modelsToHide)")
            NotificationCenter.default.post(
                name: .hideModels,
                object: nil,
                userInfo: ["modelNames": Array(modelsToHide)]
            )
        }
        
        // Find models that need to be shown
        let modelsToShow = sceneModelSet.subtracting(visibleModels)
        if !modelsToShow.isEmpty {
            print("🟢 Showing models: \(modelsToShow)")
            NotificationCenter.default.post(
                name: .showModels,
                object: nil,
                userInfo: ["modelNames": Array(modelsToShow)]
            )
        }
        
        // Update our tracking state
        visibleModels = sceneModelSet
    }
    
    // Helper function to check if a model is visible
    func isVisible(_ modelName: String) -> Bool {
        visibleModels.contains(modelName)
    }
    
    // Function to get current visible models
    func getCurrentVisibleModels() -> [String] {
        Array(visibleModels)
    }
}
