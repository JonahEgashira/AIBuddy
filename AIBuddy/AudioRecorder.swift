import Foundation
import Combine
import AVFoundation

class AudioRecorder: ObservableObject {
    internal var audioRecorder: AVAudioRecorder?
    @Published var audioURL: URL?
    @Published var isRecording: Bool = false

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            // Handle the error if setting up the audio session fails
            return
        }

        audioSession.requestRecordPermission { allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.recordAudio()
                    self.isRecording = true
                } else {
                    // Print an error message if the user doesn't allow recording
                    print("User denied access to recording")
                }
            }
        }
    }

    // Record the audio
    func recordAudio() {
        let audioFilename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("recording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            audioURL = audioFilename
        } catch {
            // Handle the error if the audio recorder fails to record
            // Print the error to the console
            print("Error recording audio: \(error.localizedDescription)")
            return
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        self.isRecording = false
    }
}
