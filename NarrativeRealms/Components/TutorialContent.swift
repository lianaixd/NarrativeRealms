import SwiftUI

// TutorialContent.swift

enum TutorialAction {
    case openPalette
    case disableNextButton
    case enableNextButton
    case showModel(String)
    case hideModel(String)
    case showModels([String])
    case hideModels([String])
    case requireSnapTo(String)
    case playAnimation(String, String)
    case none
}

struct TutorialStep {
    let id: Int
    let message: AttributedString
    let isSpecialStep: Bool
    let image: String
    let header: String
    let actions: [TutorialAction]
    
    var models: [String] {
        TutorialContent.modelsForStep(id)
    }

    init(id: Int,
         message: String,
         isSpecialStep: Bool = false,
         image: String = "tagImg",
         header: String = "Tag",
         actions: [TutorialAction] = [.none])
    {
        self.id = id
        // Using try! in init since these are static strings we control
        self.message = try! AttributedString(markdown: message)
        self.isSpecialStep = isSpecialStep
        self.image = image
        self.header = header
        self.actions = actions
    }
}

class TutorialContent {
    static let steps: [TutorialStep] = [
        TutorialStep(
            id: 1,
            message: "Hi, I'm Tag! I'll be your guide. Let's write a story together!"
        ),
        TutorialStep(
            id: 2,
            message: "In Narrative Realms, we get to create a world and tell a story in real-time.",
            actions: []
        ),
        TutorialStep(
            id: 3,
            message: "The **Genre** button here lets us pick a storytelling style. For now, select Fantasy, and let's see what happens!",
            actions: [.disableNextButton]
        ),
        TutorialStep(
            id: 4,
            message: "As we build our story, more and more parts of this fantasy world will come to life on it.",
            actions: []
        ),
        TutorialStep(
            id: 5,
            message: "The **Story Path** button here offers different paths for different kinds of tales. Each path has ups and downs, just like any great story!",
            actions: [.disableNextButton]
        ),
        TutorialStep(
            id: 6,
            message: "See how this path has high points and low points? Each part of the path represents good and bad moments in the story.",
            actions: []
        ),
        TutorialStep(
            id: 7,
            message: "The beginning is up high, and the end is also up high—looks like it might be a happy ending!",
            actions: []
        ),
        TutorialStep(
            id: 8,
            message: "Let's make a story about me, Tag! Place me at the beginning of the story path.",
            actions: [.requireSnapTo("StorylineStep1"), .disableNextButton]
        ),
        TutorialStep(
            id: 9,
            message: "I'm feeling great up here at the start of our story! I think this adventure will start on a high note.",
            actions: []
        ),
        TutorialStep(
            id: 10,
            message: "See this microphone? When you tap it, it'll capture whatever you say to add to the story.",
            actions: []
        ),
        TutorialStep(
            id: 11,
            message: "Why not start with something classic? Tap the microphone and try saying, 'Once upon a time there was a curious villager named Tag'. Tap it again to stop recording.",
            actions: [.disableNextButton]
        ),
        TutorialStep(
            id: 12,
            message: "*Tap on the microphone to record something*",
            actions: [.disableNextButton]
        ),
        TutorialStep(
            id: 13,
            message: "Nice! Look at that—a bit of our story is written, and some of the fantasy world is coming to life on the table!",
            actions: []
        ),
        TutorialStep(
            id: 14,
            message: "Now, let's move to the middle of the story, where things get a little… dicey. Put me over there, right in the middle.",
            actions: [ .requireSnapTo("StorylineStep3"), .disableNextButton]
        ),
        TutorialStep(
            id: 15,
            message: "Yikes, I'm feeling uneasy here! This is where bad things usually happen, the lowest point of the story.",
            actions: []
        ),
        TutorialStep(
            id: 16,
            message: "*Tag explored a cave and found a dragon! He ran out as fast as he could!*", // Italic text
            actions: [ .playAnimation("dragon_anim_v03", "DragonSequence")]
        ),
        TutorialStep(
            id: 17,
            message: "Okay, let's wrap this up on a high note! Place me at the end of the story path.",
            actions: [.requireSnapTo("StorylineStep5"), .disableNextButton]
        ),
        TutorialStep(
            id: 18,
            message: "A happy ending! How about we finish with something like, 'And they all lived happily ever after'?",
            actions: []
        ),
        TutorialStep(
            id: 19,
            message: "*Tap on the microphone to record something*",
            actions: [.disableNextButton]
        ),
        TutorialStep(
            id: 20,
            message: "See? The world fills up as the story grows. We have a beginning, middle, and end!",
            actions: []
        ),
        TutorialStep(
            id: 21,
            message: "But wait! We're missing something… How did I get into that mess in the middle? Place me over there.",
            actions: [ .requireSnapTo("StorylineStep2"), .disableNextButton]
        ),
        TutorialStep(
            id: 22,
            message: "Here's a trick! Tap the lightbulb for a little inspiration.",
            actions: [ .disableNextButton]
        ),
        TutorialStep(
            id: 23,
            message: "Aha! Treasure appeared. I heard a legend of a treasure only the truly brave can find. Let's add that!",
            actions: []
        ),
        TutorialStep(
            id: 24,
            message: "Let's jump to a spot between the dragon scene and the ending. Place me there, and let's wrap up our story with a twist!",
            actions: [.requireSnapTo("StorylineStep4"), .disableNextButton]
        ),
        TutorialStep(
            id: 25,
            message: "Got any ideas for how I escape this mess? If you're stuck, try the lightbulb again.",
            actions: [.disableNextButton]
        ),
        TutorialStep(
            id: 26,
            message: "This is awesome! Now, you tell the next part of the story.",
            actions: [.playAnimation("TestAnimation", "ArmourSequence"), .disableNextButton]
        ),
        TutorialStep(
            id: 27,
            message: "Nice work! Hit the Play button to play back the whole story anytime or save it to share with others.",
            actions: [.disableNextButton]
        ),
        TutorialStep(
            id: 28,
            message: "*Whispers filled the village of a hidden treasure guarded by ancient magic. Tag had often dreamed of discovering it. A treasure only the truly brave could hope to find. And now, with a heart full of courage and curiosity, his time had come to seek it out.*",
            image: "lianaImg",
            header: "Tag's Adventure",
            actions: []
        ),
        TutorialStep(
            id: 29,
            message: "Restart tutorial?",
            actions: [.disableNextButton]
        )
    ]

    static func getStep(_ id: Int) -> TutorialStep? {
        steps.first { step in step.id == id }
    }
    
    static func modelsForStep(_ stepId: Int) -> [String] {
        // Base models that are always visible
        var baseModels = ["TestAnimation"]
        
        switch stepId {
        case 1...3:
            // Just Tag visible
            return baseModels
        case 4...5:
            // Add table
            baseModels.append("_010_table_tex_v01")
            return baseModels
        case 6...7:
            // Add story path
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01"])
            return baseModels
            
        case 8...9:
            // Add storyline step indicator
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "StorylineStep1"])
            return baseModels
        case 10...12:
            // Show microphone
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "StorylineStep1"])
            return baseModels
        case 13:
            // Show forest signpost
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01", "StorylineStep1"])
            return baseModels
        case 14:
            // Show storyline step 3
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01",
                                           "StorylineStep1",  "StorylineStep3"])
            return baseModels
        case 15:
            // Remove storyline step 1
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01", "StorylineStep3"])
            return baseModels
        case 16:
            // Add dragon
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01",  "StorylineStep3",
                                          "dragon_anim_v03"])
            return baseModels
        case 17:
            // Show storyline step 5
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01",
                                          "dragon_anim_v03",  "StorylineStep3", "StorylineStep5"])
            return baseModels
        case 18...19:
            // Remove storyline step 3
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01","StorylineStep5",
                                          "dragon_anim_v03"])
            return baseModels
        case 20:
            // Add cottage
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01", "StorylineStep5",
                                          "dragon_anim_v03", "cottage_teapot_tex_v01"])
            return baseModels
        case 21:
            // Add storyline step 2
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tefinalizePanelx_v01", "signpost_forest_tex_v01", "StorylineStep5",
                                          "dragon_anim_v03", "cottage_teapot_tex_v01", "StorylineStep2"])
            return baseModels
        case 22:
            // Remove storyline step 5, add lightbulb
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01","StorylineStep2",
                                          "dragon_anim_v03", "cottage_teapot_tex_v01", "lightbulb_tex_v01"])
            return baseModels
        case 23:
            // Show treasure
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01", "StorylineStep2",
                                          "dragon_anim_v03", "cottage_teapot_tex_v01", "lightbulb_tex_v01", "treasure_tex_v01"])
            return baseModels
        case 24:
            // Show storyline step 4 and snow signpost
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01",
                                          "dragon_anim_v03", "cottage_teapot_tex_v01", "lightbulb_tex_v01", "treasure_tex_v01",
                                          "signopost_snow_tex_v01", "StorylineStep2", "StorylineStep4"])
            return baseModels
        case 25:
            // Remove storyline step 2
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01",
                                          "dragon_anim_v03", "cottage_teapot_tex_v01", "lightbulb_tex_v01", "treasure_tex_v01",
                                          "signopost_snow_tex_v01", "StorylineStep4"])
            return baseModels
        case 26...29:
            // Add signpost desert
            baseModels.append(contentsOf: ["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01",
                                          "dragon_anim_v03", "cottage_teapot_tex_v01", "lightbulb_tex_v01", "treasure_tex_v01",
                                           "signopost_snow_tex_v01", "signpost_desert_tex_v01", "StorylineStep4"])
            return baseModels
        default:
            return baseModels
        }
    }
}

