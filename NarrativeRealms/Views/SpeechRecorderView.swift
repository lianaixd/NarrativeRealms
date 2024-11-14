//
//  SpeechRecorderView.swift
//  NarrativeRealms
//
//  Created by Marc O'Cleirigh on 11/14/24.
//

import SwiftUI

struct SpeechRecorderView: View {
    @StateObject private var recordingManager = AudioRecordingManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(recordingManager.transcribedText)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            Button(action: {
                if recordingManager.isRecording {
                    recordingManager.stopRecording()
                } else {
                    try? recordingManager.startRecording()
                }
            }) {
                Text(recordingManager.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(recordingManager.isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
