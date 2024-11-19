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
    case none
}

struct TutorialStep {
    let id: Int
    let message: AttributedString
    let isSpecialStep: Bool
    let image: String
    let header: String
    let actions: [TutorialAction]

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
            message: "Hi, I'm Tag! I'll be your guide. Let's write a story together!",
            actions: [.hideModels(["_010_table_tex_v01", "storypath_tex_v01", "signpost_forest_tex_v01", "cottage_teapot_tex_v01",
                                 "lightbulb_tex_v01", "treasure_tex_v01", "signopost_snow_tex_v01", "dragon_anim_v03",
                                 "signpost_desert_tex_v01", "microphone_tex_v01", "Indicator8",
                                 "Indicator14", "Indicator17", "Indicator21", "Indicator24"])]
        ),
        TutorialStep(
            id: 2,
            message: "In Narrative Realms, we get to create a world and tell a story in real-time."
        ),
        TutorialStep(
            id: 3,
            message: "The **Genre** button here lets us pick a storytelling style. For now, select Fantasy, and let's see what happens!",
            actions: [.disableNextButton]
        ),
        TutorialStep(
            id: 4,
            message: "As we build our story, more and more parts of this fantasy world will come to life on it.",
            actions: [.showModels(["_010_table_tex_v01"])]
        ),
        TutorialStep(
            id: 5,
            message: "The **Story Path** button here offers different paths for different kinds of tales. Each path has ups and downs, just like any great story!",
            actions: [.disableNextButton]
        ),
        TutorialStep(
            id: 6,
            message: "See how this path has high points and low points? Each part of the path represents good and bad moments in the story.",
            actions:  [.showModels(["_010_table_tex_v01", "storypath_tex_v01"])]
        ),
        TutorialStep(
            id: 7,
            message: "The beginning is up high, and the end is also up high—looks like it might be a happy ending!"
        ),
        TutorialStep(
            id: 8,
            message: "Let's make a story about me, Tag! Place me at the beginning of the story path.",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "Indicator8"])]
        ),
        TutorialStep(
            id: 9,
            message: "I'm feeling great up here at the start of our story! I think this adventure will start on a high note.",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01"])]
        ),
        TutorialStep(
            id: 10,
            message: "See this microphone? When you tap it, it'll capture whatever you say to add to the story.",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01"])]
        ),
        TutorialStep(
            id: 11,
            message: "Why not start with something classic? Try saying, 'Once upon a time there was a curious villager named Tag'."
        ),
        TutorialStep(
            id: 12,
            message: "*Recording*"
        ),
        TutorialStep(
            id: 13,
            message: "Nice! Look at that—a bit of our story is written, and some of the fantasy world is coming to life on the table!",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01"])]
        ),
        TutorialStep(
            id: 14,
            message: "Now, let's move to the middle of the story, where things get a little… dicey. Put me over there, right in the middle.",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01", "Indicator14"])]
        ),
        TutorialStep(
            id: 15,
            message: "Yikes, I'm feeling uneasy here! This is where bad things usually happen, the lowest point of the story.",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01", "signpost_forest_tex_v01"])]
        ),
        TutorialStep(
            id: 16,
            message: "*Tag explored a cave and found a dragon! He ran out as fast as he could!*" // Italic text
        ),
        TutorialStep(
            id: 17,
            message: "Okay, let's wrap this up on a high note! Place me at the end of the story path.",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01",
                                   "signpost_forest_tex_v01", "dragon_anim_v03", "Indicator17"])]
        ),
        TutorialStep(
            id: 18,
            message: "A happy ending! How about we finish with something like, 'And they all lived happily ever after'?",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01",
                                   "signpost_forest_tex_v01", "dragon_anim_v03"])]
        ),
        TutorialStep(
            id: 19,
            message: "*Recording*"
        ),
        TutorialStep(
            id: 20,
            message: "See? The world fills up as the story grows. We have a beginning, middle, and end!",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01",
                                   "signpost_forest_tex_v01", "dragon_anim_v03", "cottage_teapot_tex_v01"])]
        ),
        TutorialStep(
            id: 21,
            message: "But wait! We're missing something… How did I get into that mess in the middle? Place me over there.",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01",
                                   "signpost_forest_tex_v01", "dragon_anim_v03", "cottage_teapot_tex_v01",
                                   "Indicator21"])]
        ),
        TutorialStep(
            id: 22,
            message: "Here's a trick! Tap the lightbulb for a little inspiration.",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01",
                                   "signpost_forest_tex_v01", "dragon_anim_v03", "cottage_teapot_tex_v01",
                                   "lightbulb_tex_v01"]), .disableNextButton]
        ),
        TutorialStep(
            id: 23,
            message: "Aha! Treasure appeared. I heard a legend of a treasure only the truly brave can find. Let's add that!",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01",
                                   "signpost_forest_tex_v01", "dragon_anim_v03", "cottage_teapot_tex_v01",
                                   "lightbulb_tex_v01", "treasure_tex_v01"])]
        ),
        TutorialStep(
            id: 24,
            message: "Let's jump to a spot between the dragon scene and the ending. Place me there, and let's wrap up our story with a twist!",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01",
                                   "signpost_forest_tex_v01", "dragon_anim_v03", "cottage_teapot_tex_v01",
                                   "lightbulb_tex_v01", "treasure_tex_v01", "signopost_snow_tex_v01", "Indicator24"])]
        ),
        TutorialStep(
            id: 25,
            message: "Got any ideas for how I escape this mess? If you're stuck, try the lightbulb again.",
            actions: [.disableNextButton, .showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01",
                                   "signpost_forest_tex_v01", "dragon_anim_v03", "cottage_teapot_tex_v01",
                                   "lightbulb_tex_v01", "treasure_tex_v01", "signopost_snow_tex_v01"])]
        ),
        TutorialStep(
            id: 26,
            message: "This is awesome! Now, you tell the next part of the story."
        ),
        TutorialStep(
            id: 27,
            message: "Nice work! Hit the Play button to play back the whole story anytime or save it to share with others.",
            actions: [.showModels(["_010_table_tex_v01", "storypath_tex_v01", "microphone_tex_v01",
                                   "signpost_forest_tex_v01", "dragon_anim_v03", "cottage_teapot_tex_v01",
                                   "lightbulb_tex_v01", "treasure_tex_v01", "signopost_snow_tex_v01",
                                   "signpost_desert_tex_v01"])]
        ),
        TutorialStep(
            id: 28,
            message: "*Whispers filled the village of a hidden treasure guarded by ancient magic. Tag had often dreamed of discovering it. A treasure only the truly brave could hope to find. And now, with a heart full of courage and curiosity, his time had come to seek it out.*",
            image: "lianaImg",
            header: "Tag's Adventure"
        ),
        TutorialStep(
            id: 29,
            message: "Restart tutorial?"
        )
    ]

    static func getStep(_ id: Int) -> TutorialStep? {
        steps.first { step in step.id == id }
    }
}
