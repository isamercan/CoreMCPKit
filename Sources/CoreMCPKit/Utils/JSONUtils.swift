//
//  JSONUtils.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation

public enum JSONUtils {
    
    /// Converts a dictionary or array into a pretty-printed JSON string.
    public static func prettyPrint(_ object: Any) -> String {
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
    
    /// Converts a JSON string into a dictionary.
    public static func decodeJSON(from string: String) -> [String: Any]? {
        guard let data = string.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let dict = jsonObject as? [String: Any] else {
            return nil
        }
        return dict
    }
    
    /// Safely serializes an object to JSON Data.
    public static func toData(_ object: Any) -> Data? {
        guard JSONSerialization.isValidJSONObject(object) else { return nil }
        return try? JSONSerialization.data(withJSONObject: object, options: [])
    }
}
