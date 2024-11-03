import SwiftUI

struct TagTutorialView: View {
    @Binding var tutorialStep: Int
    var onRestart: () -> Void

    var body: some View {
        VStack {
            Spacer()

            Image("tagImg")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())

            Text("Tag")
                .font(.headline)
                .padding(.top, 8)

            // Display text based on the tutorial step
            Group {
                if tutorialStep == 1 {
                                    Text("Hi, I'm Tag! I'll be your guide. Let's write a story together!")
                                } else if tutorialStep == 2 {
                                    Text("In Narrative Realms, we get to create a world and tell a story in real-time.")
                                } else if tutorialStep == 3 {
                                    (Text("The ")
                                     + Text("Genre").bold()
                                     + Text(" button here lets us pick a storytelling style. For now, select Fantasy, and let’s see what happens!"))
                                    .onAppear {
                                 //       openWindow(value: PaletteWindowID(id: 1).id)
                                    }
                                } else if tutorialStep == 4 {
                                    Text("As we build our story, more and more parts of this fantasy world will come to life on it.")
                                } else if tutorialStep == 5 {
                                    (Text("The ‘")
                                     + Text("Story Path").bold()
                                     + Text("’ button here offers different paths for different kinds of tales. Each path has ups and downs, just like any great story!"))
                                    .onAppear {
                                 //       openWindow(value: PaletteWindowID(id: 1).id)
                                    }
                                } else if tutorialStep == 6 {
                    Text("See how this path has high points and low points? Each part of the path represents good and bad moments in the story.")
                } else if tutorialStep == 7 {
                    Text("The beginning is up high, and the end is also up high—looks like it might be a happy ending!")
                } else if tutorialStep == 8 {
                    Text("Let’s make a story about me, Tag! Place me at the beginning of the story path.")
                } else if tutorialStep == 9 {
                    Text("I’m feeling great up here at the start of our story! I think this adventure will start on a high note.")
                } else if tutorialStep == 10 {
                    Text("See this microphone? When you pick it up, and it’ll capture whatever you say to add to the story.")
                } else if tutorialStep == 11 {
                    Text("Why not start with something classic? Try saying, ‘Once upon a time there was a curious villager named tag’.")
                } else if tutorialStep == 12 {
                    Text("*Record speech into new window* (remove this later)")
                } else if tutorialStep == 13 {
                    Text("Nice! Look at that—a bit of our story is written, and some of the fantasy world is coming to life on the table!")
                } else if tutorialStep == 14 {
                    Text("Now, let’s move to the middle of the story, where things get a little… dicey. Put me over there, right in the middle.")
                } else if tutorialStep == 15 {
                    Text("Yikes, I’m feeling uneasy here! This is where bad things usually happen…")
                } else if tutorialStep == 16 {
                    Text("Tag explored a cave and found a dragon! He ran out as fast as he could!")
                        .italic()
                } else if tutorialStep == 17 {
                    Text("Okay, let’s wrap this up on a high note! Place me at the end of the story path.")
                } else if tutorialStep == 18 {
                    Text("A happy ending! How about we finish with something like, ‘And they all lived happily ever after’?")
                } else if tutorialStep == 19 {
                    Text("*Record speech into new window* (remove this later)")
                } else if tutorialStep == 20 {
                    Text("See? The world fills up as the story grows. We have a beginning, middle, and end!")
                } else if tutorialStep == 21 {
                    Text("But wait! We’re missing something… How did I get into that mess in the middle? Place me over there.")
                } else if tutorialStep == 22 {
                    Text("Here’s a trick! Tap the lightbulb for a little inspiration.")
                } else if tutorialStep == 23 {
                    Text("Aha! A treasure chest appeared. I heard a legend of a treasure only the truly brave can find. Let’s add that!")
                } else if tutorialStep == 24 {
                    Text("Let’s jump to a spot between the dragon scene and the ending. Place me there, and let’s wrap up our story with a twist!")
                } else if tutorialStep == 25 {
                    Text("Got any ideas for how I escape this mess? If you’re stuck, try the lightbulb again.")
                } else if tutorialStep == 26 {
                    Text("This is awesome! Now, you tell the next part of the story.")
                } else if tutorialStep == 27 {
                    Text("Nice work! You can play back the whole story anytime or save it to share with others.")
                } else if tutorialStep == 28 {
                    Text("Once upon a time there was a curious boy named Tag...this continues as animation plays")
                }   else if tutorialStep == 29 {
                    Text("Restart tutorial?")
                }
            }
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)

            Divider()
                .padding(.vertical, 8)

            // Button layout for Back and Next
            HStack {
                           if tutorialStep > 1 {
                               Button("Back") {
                                   tutorialStep -= 1
                               }
                               .buttonStyle(.plain)
                               .padding(.vertical, 8)
                           }

                           Spacer()

                           if tutorialStep == 29 {
                               Button("Restart") {
                                   onRestart()
                               }
                               .padding(.vertical, 8)
                               .buttonStyle(.borderedProminent)
                           } else {
                               Button("Next") {
                                   tutorialStep += 1
                               }
                               .padding(.vertical, 8)
                               .buttonStyle(.borderedProminent)
                               .disabled(tutorialStep == 3 || tutorialStep == 5 || tutorialStep == 27)
                           }
                       }

                       Spacer()
                   }
                   .padding()
               }
           }
