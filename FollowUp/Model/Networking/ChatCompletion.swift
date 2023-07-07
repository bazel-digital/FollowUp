//
//  ChatCompletion.swift
//  FollowUp
//
//  Created by Aaron Baw on 16/03/2023.
//

import Foundation

// MARK: - ChatCompletionResponse
struct ChatCompletionRequest: Codable {
    let model: OpenAIModel
    let messages: [ChatCompletionMessage]
}

// MARK: - Message
struct ChatCompletionMessage: Codable {
    
    // MARK: - Enums
    enum Role: String, Codable {
        case user
        case system
        case assistant
    }
    
    let role: Role
    let content: String
}


// MARK: - ChatCompletionResponse
struct ChatCompletionResponse: Codable {
    let id, object: String
    let created: Int
    let choices: [Choice]
    let usage: ChatCompletionUsage
}

// MARK: - Choice
struct Choice: Codable {
    let index: Int
    let message: ChatCompletionMessage
    let finishReason: String

    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

// MARK: - Usage
struct ChatCompletionUsage: Codable {
    let promptTokens, completionTokens, totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
