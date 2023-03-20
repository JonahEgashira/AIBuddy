import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject private var audioRecorder = AudioRecorder()
    @State private var audioPlayer: AVAudioPlayer?
    
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
