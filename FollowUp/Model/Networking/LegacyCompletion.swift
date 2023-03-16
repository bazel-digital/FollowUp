//
//  LegacyCompletion.swift
//  FollowUp
//
//  Created by Aaron Baw on 16/03/2023.
//

import Foundation


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
    
    var model: OpenAIModel
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


enum OpenAIModel: String, Codable {
    case textDavinci3 = "text-davinci-003"
    case textCurie1 = "text-curie-001"
    case textBabbage1 = "text-babbage-001"
    case textAda1 = "text-ada-001"
    case gpt35Turbo0301 = "gpt-3.5-turbo-0301"
    case gpt35Turbo = "gpt-3.5-turbo"
    case gpt4 = "gpt-4"
    case gpt40314 = "gpt-4-0314"
}
