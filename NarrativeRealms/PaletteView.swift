import SwiftUI

struct PaletteView: View {
    @Binding var tutorialStep: Int
    @State private var selectedGenre: String? = nil
    @State private var selectedStoryPath = "Story Path 1"
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
                    .padding(.leading, collapsed ? 0 : 16) // Remove leading padding when collapsed

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
                .padding(.trailing, 16) // Adjusts distance from right edge
            }
            .padding(.top, collapsed ? 8 : 40) // Reduce top padding when collapsed
            .padding(.bottom, collapsed ? 0 : 20) // Adjust bottom padding based on state
            
            if !collapsed {
                VStack {
                    HStack(alignment: .top, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Genre")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.leading, 18)

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
                                .padding(.leading, 18)
                            
                            Picker("Select Story Path", selection: $selectedStoryPath) {
                                ForEach(storyPaths, id: \.self) { path in
                                    Text(path)
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(minWidth: 180)
                            .padding(.leading, 2)
                            .disabled(true) // Disable the Story Path picker for now
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
        PaletteView(tutorialStep: .constant(3))
            .previewLayout(.sizeThatFits)
    }
}
