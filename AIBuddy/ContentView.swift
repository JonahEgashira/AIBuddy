import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject private var audioRecorder = AudioRecorder()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var transcription = ""
    @State private var responseText = ""
    
    private let whisperAPIManager = WhisperAPIManager()
    private let chatGPTAPIManager = ChatGPTAPIManager()
    
    var body: some View {
        VStack {
            Text(transcription)
                .padding()
                .padding(.top, 100)
            
            Text(responseText)
                .padding()
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 4)
                    .frame(width: 90, height: 90)
                Circle()
                    .foregroundColor(.blue)
                    .frame(width: audioRecorder.isRecording ? 40 : 80, height: audioRecorder.isRecording ? 40 : 80)
                    .opacity(audioRecorder.isRecording ? 0 : 1)
                
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.blue)
                    .frame(width: audioRecorder.isRecording ? 20 : 0, height: audioRecorder.isRecording ? 20 : 0)
            }
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    if !audioRecorder.isRecording {
                        audioRecorder.startRecording()
                    }
                })
                    .onEnded({ _ in
                        if audioRecorder.isRecording {
                            audioRecorder.stopRecording()
                            processAudio()
                        }
                    })
            )
            .padding()
        }
    }
    
    private func processAudio() {
        if let audioURL = audioRecorder.audioURL {
            whisperAPIManager.transcribleAudio(url: audioURL) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let transcribedText):
                        self.transcription = transcribedText
                        
                        chatGPTAPIManager.generateResponse(text: transcribedText) { chatGPTResult in
                            switch chatGPTResult {
                            case.success(let chatGPTResponse):
                                self.responseText = chatGPTResponse
                            case.failure(let chatGPTError):
                                print("ChatGPT Error: \(chatGPTError.localizedDescription)")
                            }
                        }
                        
                    case .failure(let error):
                        print("Error transcribing audio: \(error)")
                        self.transcription = "Error transcribing audio"
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
