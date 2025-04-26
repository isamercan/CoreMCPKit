import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey
        case invalidKey
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = ProcessInfo.processInfo.environment[key] else {
            throw Error.missingKey
        }

        guard let value = T(object) else {
            throw Error.invalidKey
        }

        return value
    }
}

extension Configuration {
    static var openAIApiKey: String {
        get throws {
            try value(for: "OPENAI_API_KEY")
        }
    }
} 