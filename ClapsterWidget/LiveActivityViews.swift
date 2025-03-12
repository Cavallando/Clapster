import SwiftUI
import WidgetKit
import ActivityKit

// MARK: - Reusable UI Components

/// A styled countdown text display
struct CountdownDisplay: View {
    let seconds: Int
    let style: CountdownStyle
    
    enum CountdownStyle {
        case large
        case regular
        case compact
        case minimal
    }
    
    var body: some View {
        switch style {
        case .large:
            Text(TimeFormatter.formatCountdown(seconds: seconds))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)
        case .regular:
            Text(TimeFormatter.formatCountdown(seconds: seconds))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.white)
                .lineLimit(1)
        case .compact:
            Text(TimeFormatter.formatCompactCountdown(seconds: seconds))
                .font(.system(size: 10, weight: .medium))
                .monospacedDigit()
                .foregroundColor(.white)
                .lineLimit(1)
        case .minimal:
            Text(TimeFormatter.formatMinimalCountdown(seconds: seconds))
                .font(.system(size: 12, weight: .medium))
                .monospacedDigit()
                .foregroundColor(.white)
                .lineLimit(1)
        }
    }
}

/// A styled event date/time display
struct EventTimeDisplay: View {
    let date: Date
    let style: TimeStyle
    
    enum TimeStyle {
        case full
        case compact
        case timeOnly
    }
    
    var body: some View {
        switch style {
        case .full:
            VStack(alignment: .trailing, spacing: 1) {
                Text(date, style: .time)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                
                Text(date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        case .compact:
            Text(TimeFormatter.formatTime(date))
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
        case .timeOnly:
            Text(TimeFormatter.formatCompactTime(date))
                .font(.system(size: 10))
                .foregroundColor(.white)
        }
    }
}

/// A styled progress indicator for countdown
struct CountdownProgress: View {
    let progress: Double
    let compact: Bool
    
    var body: some View {
        ProgressView(value: progress, total: 1.0)
            .progressViewStyle(LinearProgressViewStyle(tint: .white))
            .frame(maxWidth: compact ? 150 : .infinity)
            .frame(height: compact ? 2 : 4)
    }
}

/// A clap now indicator with celebration
struct ClapNowView: View {
    let compact: Bool
    
    var body: some View {
        if compact {
            Text("CLAP NOW!")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
        } else {
            VStack(spacing: 8) {
                Text("CLAP NOW!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("👏  👏  👏")
                    .font(.system(size: compact ? 14 : 32))
                    .padding(.top, compact ? 2 : 4)
            }
        }
    }
} 