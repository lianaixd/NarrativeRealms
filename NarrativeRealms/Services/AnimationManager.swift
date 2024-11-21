//
//  AnimationManager.swift
//  NarrativeRealms
//
//  Created by Marc O'Cleirigh on 11/20/24.
//

import Foundation
import RealityKit

class AnimationManager {
    private var currentController: AnimationPlaybackController?
    private var entity: Entity
    private var animations: [String: AnimationResource] = [:]
    
    init(entity: Entity) {
        self.entity = entity
        loadAnimations()
    }
    
    private func loadAnimations() {
        // Store animations from the entity's available animations
        print("📋 Available animations for \(entity.name):")
        for animation in entity.availableAnimations {
            if let name = animation.name {
                print("  - Name: \(name)")
               //  print("  - Definition type: \(type(of: animation.definition))")
                // print("  - Definition: \(animation.definition)")
                animations[name] = animation
            }
        }
    }
    
    func playAnimation(named: String,
                       transitionDuration: TimeInterval = 0,
                       blendLayerOffset: Int = 0,
                       separateAnimatedValue: Bool = false)
    {
        if named == "ArmourSequence" {
            guard let defaultToArmour = entity.availableAnimations.first(where: { $0.name == "DefaultToArmour" }),
                  let armourIdle = entity.availableAnimations.first(where: { $0.name == "ArmourIdle" })
            else {
                print("❌ Required animations not found")
                return
            }
            let repeatingIdle = armourIdle.repeat(count: 1000)
            // Create sequence: DefaultToArmour followed by repeating ArmourIdle
            let tagArmourSequence = try! AnimationResource.sequence(with: [
                defaultToArmour,
                repeatingIdle
            ])
            
            // Stop current animation if playing
            currentController?.stop()

            // Play new animation
            currentController = entity.playAnimation(
                tagArmourSequence,
                transitionDuration: transitionDuration,
                blendLayerOffset: blendLayerOffset,
                separateAnimatedValue: separateAnimatedValue
            )
        } else if named == "DragonSequence" {
            guard let dragonAppear = entity.availableAnimations.first(where: { $0.name == "Appear" }),
                  let dragonBreathe = entity.availableAnimations.first(where: { $0.name == "Breathe" })
            else {
                print("❌ Required animations not found")
                return
            }
            let repeatingIdle = dragonBreathe.repeat(count: 1000)
            // Create sequence: DefaultToArmour followed by repeating ArmourIdle
            let dragonSequence = try! AnimationResource.sequence(with: [
                dragonAppear,
                repeatingIdle
            ])
            
            // Stop current animation if playing
            currentController?.stop()

            // Play new animation
            currentController = entity.playAnimation(
                dragonSequence,
                transitionDuration: transitionDuration,
                blendLayerOffset: blendLayerOffset,
                separateAnimatedValue: separateAnimatedValue
            )
        }
    }
    
    func stopCurrentAnimation() {
        currentController?.stop()
        currentController = nil
    }
}
