import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject private var audioRecorder = AudioRecorder()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var transcription = ""
    
    private let whisperAPIManager = WhisperAPIManager()
    
    var body: some View {
        VStack {
            Button(action: {
                if audioRecorder.isRecording == true {
                    audioRecorder.stopRecording()
                } else {
                    audioRecorder.startRecording()
                }
            }) {
                Text(audioRecorder.isRecording ? "Stop Recording" : "Start Recording")
            }
            .padding()
            
            Button(action: playRecording) {
                Text("Play Recording")
            }
            .padding()
            .disabled(audioRecorder.audioURL == nil)
            
            Button(action: {
                if let audioURL = audioRecorder.audioURL {
                    audioRecorder.stopRecording()
                    whisperAPIManager.transcribleAudio(url: audioURL) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let transcribedText):
                                self.transcription = transcribedText
                            case .failure(let error):
                                print("Error transcribing audio: \(error)")
                                self.transcription = "Error transcribing audio"
                            }
                        }
                    }
                }
            }) {
                Text("Transcrible Audio")
            }
            .padding()
            .disabled(audioRecorder.audioURL == nil || audioRecorder.isRecording)
            
            Text(transcription)
                .padding()
        }
    }
    
    // Play the recording
    func playRecording() {
        guard let audioURL = audioRecorder.audioURL else { return }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.volume = 10.0
            audioPlayer?.play()
        } catch {
            print("Error playing recording: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
