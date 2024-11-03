import SwiftUI

extension Notification.Name {
    static let resetApp = Notification.Name("resetApp")
}

struct PaletteView: View {
    @Binding var tutorialStep: Int
    @State private var selectedGenre: String? = nil
    @State private var selectedStoryShape: String? = nil
    @State private var collapsed = false

    @Environment(\.dismissWindow) private var dismissWindow

    let genres = ["Fantasy", "Science Fiction", "Gothic", "Mystery"]
    let storyShapes = ["Story Shape 1", "Story Shape 2", "Story Shape 3", "Story Shape 4", "Story Shape 5", "Story Shape 6", "Story Shape 7"]

    var body: some View {
        VStack(spacing: 20) {
            // Header with optional Play button and collapse button
            HStack {
                if tutorialStep >= 27 {
                    Button(action: {
                        playButtonTapped()
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.title)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Spacer()

                Text("Tag's Adventure (Tutorial)")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: true, vertical: false)

                Spacer()

                Button(action: {
                    withAnimation {
                        collapsed.toggle()
                    }
                }) {
                    Image(systemName: "rectangle.compress.vertical")
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 8)
            .padding(.bottom, collapsed ? 0 : 20)

            if !collapsed {
                VStack {
                    // Arrange pickers in HStack
                    HStack(alignment: .top, spacing: 40) {
                        // Genre Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Genre")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Picker("Select one", selection: Binding(
                                get: { self.selectedGenre },
                                set: { newValue in
                                    if newValue == "Fantasy" {
                                        self.selectedGenre = newValue
                                        if tutorialStep == 3 {
                                            tutorialStep = 4 // Advance to the next tutorial step
                                        }
                                    } else {
                                        self.selectedGenre = newValue
                                    }
                                }
                            )) {
                                Text("Select one").tag(nil as String?)
                                ForEach(genres, id: \.self) { genre in
                                    Text(genre)
                                        .tag(genre as String?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(minWidth: 180)
                        }

                        // Story Shape Picker (Enabled on or after Step 5)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Story Shape")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Picker("Select one", selection: Binding(
                                get: { self.selectedStoryShape },
                                set: { newValue in
                                    if newValue == "Story Shape 1" {
                                        self.selectedStoryShape = newValue
                                        if tutorialStep == 5 {
                                            tutorialStep = 6 // Advance to the next tutorial step
                                        }
                                    } else {
                                        self.selectedStoryShape = newValue
                                    }
                                }
                            )) {
                                Text("Select one").tag(nil as String?)
                                ForEach(storyShapes, id: \.self) { shape in
                                    Text(shape)
                                        .tag(shape as String?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(minWidth: 180)
                            .disabled(tutorialStep < 5)
                        }
                    }
                    .padding(.horizontal, 40)

                    Spacer()

                    // SharePlay Button (Appears at Step 5)
                    if tutorialStep >= 3 {
                        Button(action: {
                            // Placeholder action
                        }) {
                            Label("SharePlay", systemImage: "shareplay")
                                .font(.title3)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(true)
                        .padding(.bottom, 30)
                        .padding(.top, 30)
                    }
                }
                .transition(.move(edge: .bottom))
            }
        }
        .padding()
        .frame(height: collapsed ? 80 : nil)
        .onReceive(NotificationCenter.default.publisher(for: .resetApp)) { _ in
            dismissWindow()
        }
    }

    // New function to handle play button tap
    private func playButtonTapped() {
        if tutorialStep == 27 {
            tutorialStep = 28 // Advance to the next tutorial step
        }
        // Add any additional actions needed when the play button is tapped
    }
}
