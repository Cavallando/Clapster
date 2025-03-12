import Foundation
import ActivityKit

/// Helper utilities for Live Activities
enum ActivityHelpers {
    /// Calculate progress value for a countdown
    static func calculateProgress(currentSeconds: Int, targetDate: Date) -> Double {
        if currentSeconds <= 0 {
            return 1.0
        }
        
        // Calculate based on the initial total time
        let initialSeconds = Date().distance(to: targetDate)
        
        if initialSeconds <= 0 {
            return 1.0
        }
        
        let progress = 1.0 - (Double(currentSeconds) / initialSeconds)
        return min(max(progress, 0.0), 1.0) // Clamp between 0 and 1
    }
    
    /// Get appropriate description based on time remaining
    static func getDescription(secondsRemaining: Int, isComplete: Bool) -> String {
        if isComplete {
            return "Clap! Clap! Clap!"
        } else if secondsRemaining <= 5 * 60 { // 5 minutes or less
            return "Get ready to clap!"
        } else {
            return "We clapping today!"
        }
    }
} 