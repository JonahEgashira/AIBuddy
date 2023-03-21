//
//  WhisperAPIManager.swift
//  AIBuddy
//
//  Created by Jonah Egashira on 2023/03/20.
//

import Foundation

// This class handles the API calls to the OpenAI Whisper API
class WhisperAPIManager {
    private let apiKey = Secrets.OPENAI_API_KEY
    
    func transcribleAudio(url: URL, completion: @escaping (Result<String, Error>) -> Void) {
        // Create URL for API request
        guard let apiURL = URL(string: "https://api.openai.com/v1/audio/transcriptions") else {
            return
        }
        
        // Get audioFile
        guard let audioData = try? Data(contentsOf: url) else {
            print("Error reading audio file data")
            return
        }
        
        // Create request
        var request = URLRequest(url: apiURL)
        let boundary = "Boundary-\(UUID().uuidString)"
        
        // Set request headers
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create multipart form data
        var requestData = Data()
        requestData.append("--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.mp3\"\r\n".data(using: .utf8)!)
        requestData.append("Content-Type: audio/mpeg\r\n\r\n".data(using: .utf8)!)
        requestData.append(audioData)
        requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        requestData.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        requestData.append("whisper-1".data(using: .utf8)!)
        requestData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = requestData
        
        // Send API request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("No data receieved from API")
                return
            }
            
            if response.statusCode != 200 {
                print("API returned non-200 status code: \(response.statusCode)")
                if let jsonError = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Error response: \(jsonError)")
                }
                return
            }
            
            do {
                // Parse JSON response
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let transcription = jsonResponse?["text"] as? String {
                    completion(.success(transcription))
                } else {
                    print(jsonResponse ?? "")
                    print("Error parsing JSON response")
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
