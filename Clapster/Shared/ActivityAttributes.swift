import Foundation
import ActivityKit

// This file is shared between the main app and the widget extension
public struct ClapsterWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        let countdownSeconds: Int
        let clapTimestamp: Date
        let clapDescription: String
        let isComplete: Bool
        let initialDuration: Int?
    }

    public var name: String
    
    public init(name: String) {
        self.name = name
    }
} 
