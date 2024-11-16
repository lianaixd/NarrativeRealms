//
//  TranscriptionView.swift
//  NarrativeRealms
//
//  Created by Marc O'Cleirigh on 11/15/24.
//

import SwiftUI

struct TranscriptionWindowID: Hashable, Codable {
    var id: Int
    var text: String
}

struct TranscriptionView: View {
    let text: String
    @State private var collapsed = false
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        VStack(spacing: 20) {
            // Header similar to PaletteView
            HStack {
                Spacer()
                
                Text("Transcription")
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
                // Transcribed text content
                ScrollView {
                    Text(text)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                        )
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
}
