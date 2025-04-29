import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey
        case invalidKey
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        // First try to get from environment
        if let object = ProcessInfo.processInfo.environment[key],
           let value = T(object) {
            return value
        }
        
        // If not found in environment, use Env.swift
        switch key {
        case "OPENAI_API_KEY":
            return "Env.openAIApiKey" as! T
        default:
            throw Error.missingKey
        }
    }
}

extension Configuration {
    static var openAIApiKey: String {
        get throws {
            try value(for: "OPENAI_API_KEY")
        }
    }
} 
