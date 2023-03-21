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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
