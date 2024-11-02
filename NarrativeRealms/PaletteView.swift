import SwiftUI

struct PaletteView: View {
    @Binding var tutorialStep: Int
    @State private var selectedGenre: String? = nil
    @State private var selectedStoryPath: String? = nil
    @State private var collapsed = false // State to track if the view is collapsed

    let genres = ["Fantasy", "Science Fiction", "Gothic", "Mystery"]
    let storyPaths = (1...7).map { "Story Path \($0)" }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                if collapsed {
                    Spacer()
                }
                
                Text("Tag's Adventure (Tutorial)")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.leading, 8) // Consistent padding on the left side

                if collapsed {
                    Spacer()
                }

                Button(action: {
                    withAnimation {
                        collapsed.toggle()
                    }
                }) {
                    Image(systemName: "rectangle.compress.vertical")
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle()) // Removes platter
                .padding(.trailing, 8) // Adjusted for consistent spacing on right side
            }
            .padding(.top, 8) // Consistent top padding
            .padding(.bottom, collapsed ? 0 : 20) // Adjusted bottom padding based on state
            
            if !collapsed {
                VStack {
                    HStack(alignment: .top, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Genre")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.leading, 40)

                            Picker("Select one", selection: Binding(
                                get: { self.selectedGenre },
                                set: { newValue in
                                    if newValue == "Fantasy" {
                                        self.selectedGenre = newValue
                                        tutorialStep = 4 // Advance to the next tutorial step
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
                            .padding(.leading, 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Story Path")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.leading, 38)
                            
                            Picker("Select Story Path", selection: Binding(
                                get: { self.selectedStoryPath },
                                set: { newValue in
                                    if newValue == "Story Path 1" {
                                        self.selectedStoryPath = newValue
                                        tutorialStep = 6 // Advance to the next tutorial step
                                    } else {
                                        self.selectedStoryPath = newValue
                                    }
                                }
                            )) {
                                Text("Select one").tag(nil as String?)
                                ForEach(storyPaths, id: \.self) { path in
                                    Text(path)
                                        .tag(path as String?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(minWidth: 180)
                            .padding(.leading, 2)
                            .disabled(tutorialStep < 5) // Enable only at step 5
                        }
                    }
                    
                    Spacer()

                    Button(action: {
                        // Placeholder action, button is disabled
                    }) {
                        Label("SharePlay", systemImage: "shareplay")
                            .font(.title3)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(true)
                    .padding(.bottom, 30)
                    .padding(.top, 30)
                }
                .transition(.move(edge: .bottom)) // Elements move downward when disappearing
            }
        }
        .frame(height: collapsed ? 80 : nil) // Set height only when collapsed
        .padding()
    }
}

struct PaletteView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteView(tutorialStep: .constant(5))
            .previewLayout(.sizeThatFits)
    }
}
