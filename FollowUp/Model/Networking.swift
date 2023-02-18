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
        
        var rawValue: String {
            switch self {
            case .gptTextCompletion:
                return "https://api.openai.com/v1/completions"
            }
        }
        
    }
    
    static func sendRequestToGPT3(prompt: String) -> AnyPublisher<String, Error> {
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
    
    static func sendRequestToGPT3(prompt: String) -> Future<String, Error> {
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
    
    static func sendRequestToGPT3(
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
}

struct GPT3Response: Codable {
    let id, object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
    
    struct Choice: Codable {
        let text: String
        let index: Int
        let logprobs: Int?
        let finishReason: String

        enum CodingKeys: String, CodingKey {
            case text, index, logprobs
            case finishReason = "finish_reason"
        }
    }
    
    struct Usage: Codable {
        let promptTokens, completionTokens, totalTokens: Int

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

struct GPT3Request: Codable {
    
    enum GPT3Model: String, Codable {
        case textDavinci3 = "text-davinci-003"
        case textCurie1 = "text-curie-001"
        case textBabbage1 = "text-babbage-001"
        case textAda1 = "text-ada-001"
    }
    
    var model: GPT3Model
    var prompt: String
    var maxTokens: Int? = Constant.ConversationStarter.defaultMaxTokenGenerationLength
    var temperature, topP, n: Int?
    var stream: Bool?
    var logprobs: Int?
    var stop: String?
    
    enum CodingKeys: String, CodingKey {
        case model, prompt
        case maxTokens = "max_tokens"
        case temperature
        case topP = "top_p"
        case n, stream, logprobs, stop
    }
}
