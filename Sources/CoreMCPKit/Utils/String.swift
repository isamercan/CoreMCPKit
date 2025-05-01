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
    
    var cleanedJSON: String {
        var result = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.hasPrefix("```json") || result.hasPrefix("```") {
            result = result.replacingOccurrences(of: "```json", with: "")
            result = result.replacingOccurrences(of: "```", with: "")
            result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return result
    }
}
