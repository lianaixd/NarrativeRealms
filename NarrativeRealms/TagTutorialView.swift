import SwiftUI

struct TagTutorialView: View {
    @State private var tutorialStep = 1 // Track the current step in the tutorial
    @State private var nextPaletteWindowID = PaletteWindowID(id: 1) // Track the next window ID
    @Environment(\.openWindow) private var openWindow // Access openWindow environment

    var body: some View {
        VStack {
            Spacer() // Top spacer to keep consistent vertical position

            Image("tagImg")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100) // Circle diameter
                .clipShape(Circle()) // Clips the image into a circular shape

            Text("Tag")
                .font(.headline)
                .padding(.top, 8)

            // Conditionally display text based on the tutorial step
            if tutorialStep == 1 {
                Text("Hi, I'm Tag! I'll be your guide. Let's write a story together!")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            } else if tutorialStep == 2 {
                Text("In Narrative Realms, we get to create a world and tell a story in real-time.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            } else if tutorialStep == 3 {
                (Text("The ")
                    + Text("Genre").bold()
                    + Text(" button here lets us pick a storytelling style. For now, select Fantasy, and let’s see what happens!"))
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            Divider()
                .padding(.vertical, 8)

            // HStack for Back and Next buttons
            HStack {
                if tutorialStep > 1 {
                    Button("Back") {
                        tutorialStep -= 1 // Move back to the previous step
                    }
                    .buttonStyle(.plain) // Removes platter or background styling
                    .padding(.vertical, 8)
                }

                Spacer() // Space between Back and Next buttons

                Button("Next") {
                    if tutorialStep == 2 {
                        // Open PaletteView as a separate window on step 3
                        openWindow(value: nextPaletteWindowID.id)
                        nextPaletteWindowID.id += 1
                    }
                    tutorialStep += 1 // Move to the next step
                }
                .padding(.vertical, 8)
                .buttonStyle(.borderedProminent)
            }

            Spacer() // Bottom spacer to keep content centered in the window
        }
        .padding()
    }
}
