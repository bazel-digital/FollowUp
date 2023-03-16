//
//  Networking.swift
//  FollowUp
//
//  Created by Aaron Baw on 07/02/2023.
//

import Combine
import Foundation

enum Networking {
    
    static let jsonDecoder: JSONDecoder = .init()
    static let jsonEncoder: JSONEncoder = .init()
    
    enum Endpoint {
        case gptTextCompletion
        case gptChatCompletion
        
        var rawValue: String {
            switch self {
            case .gptTextCompletion:
                return "https://api.openai.com/v1/completions"
            case .gptChatCompletion:
                return "https://api.openai.com/v1/chat/completions"
            }
        }
        
    }
    
    static func sendTextCompletionRequest(prompt: String) -> AnyPublisher<String, Error> {
        let endpoint: Endpoint = .gptTextCompletion
        let apiKey = Constant.Secrets.chatGPTApiKey
        let requestURL = URL(string: endpoint.rawValue)!
        var request = URLRequest(url: requestURL)
        
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: GPT3Response.self, decoder: Self.jsonDecoder)
            .map { $0.choices[0].text }
            .eraseToAnyPublisher()
    }
    
    static func sendTextCompletionRequest(prompt: String) -> Future<String, Error> {
        return Future { promise in
            let endpoint: Endpoint = .gptTextCompletion
            let apiKey = Constant.Secrets.chatGPTApiKey
            let requestURL = URL(string: endpoint.rawValue)!
            var request = URLRequest(url: requestURL)
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    guard let data = data else {
                        promise(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                        return
                    }
                    
                    do {
                        let response = try JSONDecoder().decode(GPT3Response.self, from: data)
                        promise(.success(response.choices[0].text))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    static func sendTextCompletionRequest(
        prompt: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let endpoint: Endpoint = .gptTextCompletion
        let apiKey = Constant.Secrets.chatGPTApiKey
        let requestURL = URL(string: endpoint.rawValue)!
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let gpt3Request = GPT3Request(model: .textDavinci3, prompt: prompt)
        
        do {
            request.httpBody = try self.jsonEncoder.encode(gpt3Request)
        } catch {
            completion(.failure(error))
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(GPT3Response.self, from: data)
                    completion(.success(response.choices[0].text))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
        
    static func sendChatCompletionRequest(_ chatCompletionRequest: ChatCompletionRequest, completion: @escaping (Result<ChatCompletionResponse, Error>) -> Void) {
        let endpoint: Endpoint = .gptChatCompletion
        let apiKey = Constant.Secrets.chatGPTApiKey
        let requestURL = URL(string: endpoint.rawValue)!
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try self.jsonEncoder.encode(chatCompletionRequest)
        } catch {
            completion(.failure(error))
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
