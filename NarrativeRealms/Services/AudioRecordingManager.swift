//
//  AudioRecordingManager.swift
//  NarrativeRealms
//
//  Created by Marc O'Cleirigh on 11/14/24.
//

import AVFoundation
import Speech
import SwiftUI

// Notification name for when recording completes
extension Notification.Name {
    static let recordingDidComplete = Notification.Name("recordingDidComplete")
}

enum RecordingError: Error {
    case recognitionRequestFailed
    case audioSessionSetupFailed
}

class AudioRecordingManager: NSObject, ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    @Published var transcribedText = ""
    @Published var isRecording = false
    
    override init() {
        super.init()
        requestPermissions()
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("User denied speech recognition permission")
                case .restricted:
                    print("Speech recognition restricted on this device")
                case .notDetermined:
                    print("Speech recognition not yet authorized")
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            print("Recording permission granted: \(granted)")
        }
    }
    
    func startRecording() throws {
        // Ensure we're not already recording
        guard !isRecording else { return }
            
        // Reset any existing task and request
        cleanupRecognitionTask()
            
        // Configure the audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            throw RecordingError.audioSessionSetupFailed
        }
            
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
        guard let recognitionRequest = recognitionRequest else {
            throw RecordingError.recognitionRequestFailed
        }
            
        recognitionRequest.shouldReportPartialResults = true
            
        // Create and configure the input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
            
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
            
        audioEngine.prepare()
        try audioEngine.start()
            
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
                
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
                    
                if result.isFinal {
                    self.handleFinalResult()
                }
            }
                
            if error != nil {
                self.stopRecording()
            }
        }
            
        isRecording = true
    }
    
    private func handleFinalResult() {
        let finalText = transcribedText
        DispatchQueue.main.async {
            // Post notification with the final transcribed text
            NotificationCenter.default.post(
                name: .recordingDidComplete,
                object: nil,
                userInfo: ["transcribedText": finalText]
            )
        }
        stopRecording()
    }
    
    private func cleanupRecognitionTask() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil
    }
    
    func stopRecording() {
        guard isRecording else { return }
            
        // Stop the audio engine and remove the tap
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
            
        // Cleanup recognition task
        cleanupRecognitionTask()
            
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            
        isRecording = false
    }
        
    deinit {
        stopRecording()
    }
}
