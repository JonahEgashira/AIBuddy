//
//  ChatGPTAPIManager.swift
//  AIBuddy
//
//  Created by Jonah Egashira on 2023/03/21.
//

import Foundation

class ChatGPTAPIManager {
    private let apiKey = Secrets.OPENAI_API_KEY
    
    func generateResponse(text: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiURL = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": text]],
            "temperature": 0.7
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error creating JSON data")
            return
        }
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("No data recieved from API")
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let choices = jsonResponse?["choices"] as? [[String: Any]], let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any], let content = message["content"] as? String {
                    completion(.success(content))
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
