import Foundation

/// Utility for formatting time displays in a consistent way
enum TimeFormatter {
    /// Format countdown in HH:MM:SS format
    static func formatCountdown(seconds: Int) -> String {
        if seconds <= 0 {
            return "00:00:00"
        }
        
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
    /// Format countdown in a compact way (e.g., 5h, 30m, 10s)
    static func formatCompactCountdown(seconds: Int) -> String {
        if seconds <= 0 {
            return "0s"
        }
        
        if seconds >= 3600 {
            return "\(seconds / 3600)h"
        } else if seconds >= 60 {
            return "\(seconds / 60)m"
        } else {
            return "\(seconds)s"
        }
    }
    
    /// Format countdown in minimal way for tight spaces
    static func formatMinimalCountdown(seconds: Int) -> String {
        if seconds <= 0 {
            return "0"
        }
        
        if seconds >= 60 {
            return "\(seconds / 60)m"
        } else {
            return "\(seconds)s"
        }
    }
    
    /// Format time for display (hours:minutes AM/PM)
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    /// Format time in the most compact way (hours:minutes)
    static func formatCompactTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: date)
    }
    
    /// Format date in a compact readable way
    static func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd h:mm a"
        return formatter.string(from: date)
    }
} 