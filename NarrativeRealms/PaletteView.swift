import SwiftUI

struct PaletteView: View {
    @State private var selectedGenre = "Fantasy"
    @State private var selectedStoryPath = "Story Path 1"

    let genres = ["Fantasy", "Science Fiction", "Gothic", "Mystery"]
    let storyPaths = (1...7).map { "Story Path \($0)" }

    var body: some View {
        VStack(spacing: 20) {
            // Centered Header with Larger Font
            Text("Tag's Adventure (Tutorial)")
                .font(.title) // Larger font size
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 10)

            // Horizontal arrangement of Pickers with headers
            HStack(alignment: .top, spacing: 20) {
                // Genre Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Genre")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Select Genre", selection: $selectedGenre) {
                        ForEach(genres, id: \.self) { genre in
                            Text(genre)
                                .disabled(genre != "Fantasy") // Disable all except "Fantasy"
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Story Path Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Story Path")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Select Story Path", selection: $selectedStoryPath) {
                        ForEach(storyPaths, id: \.self) { path in
                            Text(path)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            
            Spacer()

            // SharePlay Button with system SharePlay icon
            Button(action: {
                // Placeholder action, button is disabled
            }) {
                Label("SharePlay", systemImage: "shareplay")
                    .font(.title3)
            }
            .buttonStyle(.borderedProminent)
            .disabled(true) // Button is disabled
            .padding(.bottom, 10)
        }
        .padding()
    }
}
