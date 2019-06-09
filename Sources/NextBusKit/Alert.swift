//
//  Alert.swift
//  NextBusKit
//
//  Created by Harry Shamansky on 3/12/17.
//  Copyright © 2017 Harry Shamansky. All rights reserved.
//

/// A service alert. This is typically displayed alongside predictions for a stop.
public struct Alert: Codable {
    
    /// The text of the alert
    public let text: String
    
    /// The priority for alerts. Only used by certain agencies.
    public let priority: AlertPriority
    
    public init(text: String, priority: AlertPriority) {
        self.text = text
        self.priority = priority
    }
}

extension Alert: Equatable {
    public static func ==(lhs: Alert, rhs: Alert) -> Bool {
        return lhs.text == rhs.text && lhs.priority == rhs.priority
    }
}

extension Alert: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(priority)
    }
}

/// An alert's priority. Low, normal, or high.
public enum AlertPriority: String, Codable {
    
    /// low priority
    case low
    
    /// normal priority
    case normal
    
    /// high priority
    case high
    
    /// Returns an alert priority for a given string
    ///
    /// - Parameter priority: The string from the API
    /// - Returns: An `AlertPriority` enum value
    public static func priorityFromString(priority: String?) -> AlertPriority {
        guard let priority = priority else {
            return .normal
        }
        
        switch priority {
        case "Low":
            return .low
        case "High":
            return .high
        default:
            return .normal
        }
    }
}

extension AlertPriority: Comparable {
    public static func < (lhs: AlertPriority, rhs: AlertPriority) -> Bool {
        if lhs == .low && (rhs == .normal || rhs == .high) {
            return true
        } else if lhs == .normal && rhs == .high {
            return true
        }
        return false
    }
}
