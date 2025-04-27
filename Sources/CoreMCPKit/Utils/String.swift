//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 27.04.2025.
//

import Foundation

public extension String {
    /// Validates the string as a date in "YYYY-MM-DD" format.
    /// - Returns: The original string if it represents a valid date that is not in the past; otherwise, `nil`.
    func validateDate() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = formatter.date(from: self) else {
            return nil
        }
        
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())
        
        if date < currentDate {
            return nil
        }
        
        return self
    }
    
    public func cleanedJSONString(_ raw: String) -> String {
        var cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        // Eğer LLM yanıtı ```json ... ``` şeklindeyse temizle
        if cleaned.hasPrefix("```json") || cleaned.hasPrefix("```") {
            cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
            cleaned = cleaned.replacingOccurrences(of: "```", with: "")
            cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return cleaned
    }
}
