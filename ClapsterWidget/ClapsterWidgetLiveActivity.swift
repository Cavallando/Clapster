//
//  ClapsterWidgetLiveActivity.swift
//  ClapsterWidget
//
//  Created by Michael Cavallaro on 3/11/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ClapsterWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ClapsterWidgetAttributes.self) { context in
            lockScreenView(context: context)
        } dynamicIsland: { context in
            dynamicIslandView(context: context)
        }
    }
    
    // MARK: - Lock Screen/Notification Banner View
    private func lockScreenView(context: ActivityViewContext<ClapsterWidgetAttributes>) -> some View {
        ZStack {
            Color(hex: "#5321A8")
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // Header
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    Text("Next Clap")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Add the date/time
                    if !context.state.isComplete {
                        EventTimeDisplay(date: context.state.clapTimestamp, style: .full)
                    }
                }
                
                // Main countdown display
                if context.state.isComplete {
                    ClapNowView(compact: false)
                } else {
                    VStack(alignment: .center, spacing: 4) {
                        // Show countdown components
                        CountdownDisplay(seconds: context.state.countdownSeconds, style: .large)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                Rectangle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                // Progress fill
                                Rectangle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: progressWidth(
                                        totalWidth: geometry.size.width, 
                                        seconds: context.state.countdownSeconds, 
                                        targetDate: context.state.clapTimestamp
                                    ), height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .frame(height: 4)
                        .padding(.horizontal, 2)
                        .padding(.top, 4)
                        
                        // Description
                        Text(context.state.clapDescription)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 2)
                    }
                }
            }
            .padding()
        }
        .activityBackgroundTint(Color.clear)
        .activitySystemActionForegroundColor(.white)
        .widgetURL(URL(string: "clapster://tab/clap"))
    }
    
    // MARK: - Dynamic Island View
    private func dynamicIslandView(context: ActivityViewContext<ClapsterWidgetAttributes>) -> DynamicIsland {
        DynamicIsland {
            DynamicIslandExpandedRegion(.center) {
                if context.state.isComplete {
                    ClapNowView(compact: true)
                } else {
                    // Countdown
                    CountdownDisplay(seconds: context.state.countdownSeconds, style: .regular)
                }
            }
            
            DynamicIslandExpandedRegion(.bottom) {
                if context.state.isComplete {
                    HStack(spacing: 8) {
                        Text("👏").font(.system(size: 14))
                        Text("👏").font(.system(size: 14))
                        Text("👏").font(.system(size: 14))
                    }
                    .padding(.vertical, 2)
                } else {
                    VStack(spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 3)
                                    .cornerRadius(1.5)
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: progressWidth(totalWidth: geometry.size.width, seconds: context.state.countdownSeconds, targetDate: context.state.clapTimestamp), height: 3)
                                    .cornerRadius(1.5)
                            }
                        }
                        .frame(height: 3)
                        .padding(.horizontal, 4)
                        
                        Text(context.state.clapDescription)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                            .padding(.horizontal, 4)
                    }
                    .padding(.vertical, 2)
                }
            }
        } compactLeading: {
            // Compact leading section
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 14))
                .foregroundColor(.white)
        } compactTrailing: {
            if context.state.isComplete {
                Text("👏")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.trailing, 2)
            } else {
                CountdownDisplay(seconds: context.state.countdownSeconds, style: .compact)
                    .padding(.trailing, 2)
            }
        } minimal: {
            if context.state.isComplete {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            } else {
                CountdownDisplay(seconds: context.state.countdownSeconds, style: .minimal)
            }
        }
        .widgetURL(URL(string: "clapster://tab/clap"))
        .keylineTint(Color(hex: "#5321A8").opacity(0.8))
    }
    
    private func progressWidth(totalWidth: CGFloat, seconds: Int, targetDate: Date) -> CGFloat {
        let timeUntilEvent = targetDate.timeIntervalSince(Date())
        
        if timeUntilEvent <= 0 {
            // Event is now or in the past
            return totalWidth
        }
        
        // Use different scales based on how far the event is
        let progress: Double
        if seconds <= 60 { // Last minute
            // Scale from 0.8 to 1.0 in the last minute
            progress = 0.8 + 0.2 * (1.0 - Double(seconds) / 60.0)
        } else if seconds <= 5 * 60 { // Last 5 minutes
            // Scale from 0.5 to 0.8 in the 5 minutes before the last minute
            progress = 0.5 + 0.3 * (1.0 - Double(seconds - 60) / (5 * 60 - 60))
        } else if seconds <= 30 * 60 { // Last 30 minutes
            // Scale from 0.2 to 0.5 in the 30 minutes before the last 5 minutes
            progress = 0.2 + 0.3 * (1.0 - Double(seconds - 5 * 60) / (30 * 60 - 5 * 60))
        } else {
            // Before the last 30 minutes, scale from 0 to 0.2
            progress = min(0.2, Double(seconds) / (8 * 60 * 60)) // Max 8 hours
        }
        
        // For debugging
        print("Progress: \(progress) for \(seconds) seconds")
        
        return totalWidth * CGFloat(progress)
    }

    private func calculateMaxDuration(date: Date) -> Int {
        // Fixed durations based on how far away the event is
        let secondsUntilEvent = Int(date.timeIntervalSince(Date()))
        
        if secondsUntilEvent <= 0 {
            return 1 // Prevent division by zero
        } else if secondsUntilEvent <= 5 * 60 { // 5 minutes
            return 5 * 60
        } else if secondsUntilEvent <= 30 * 60 { // 30 minutes
            return 30 * 60
        } else if secondsUntilEvent <= 60 * 60 { // 1 hour
            return 60 * 60
        } else {
            return 8 * 60 * 60 // 8 hours max (Live Activity limit)
        }
    }
}

// MARK: - Preview Providers
extension ClapsterWidgetAttributes {
    fileprivate static var preview: ClapsterWidgetAttributes {
        ClapsterWidgetAttributes(name: "Next Clap")
    }
}

extension ClapsterWidgetAttributes.ContentState {
    fileprivate static var thirtyMinutes: ClapsterWidgetAttributes.ContentState {
        ClapsterWidgetAttributes.ContentState(
            countdownSeconds: 30 * 60,
            clapTimestamp: Date().addingTimeInterval(30 * 60),
            clapDescription: ActivityHelpers.getDescription(secondsRemaining: 30 * 60, isComplete: false),
            isComplete: false,
            initialDuration:30 * 60
        )
    }
     
    fileprivate static var oneMinute: ClapsterWidgetAttributes.ContentState {
        ClapsterWidgetAttributes.ContentState(
            countdownSeconds: 60,
            clapTimestamp: Date().addingTimeInterval(60),
            clapDescription: ActivityHelpers.getDescription(secondsRemaining: 60, isComplete: false),
            isComplete: false,
            initialDuration:  60
        )
    }
    
    fileprivate static var fiveMinutes: ClapsterWidgetAttributes.ContentState {
        ClapsterWidgetAttributes.ContentState(
            countdownSeconds: 5 * 60,
            clapTimestamp: Date().addingTimeInterval(5 * 60),
            clapDescription: ActivityHelpers.getDescription(secondsRemaining: 5 * 60, isComplete: false),
            isComplete: false,
            initialDuration: 5 * 60
        )
    }
    
    fileprivate static var happening: ClapsterWidgetAttributes.ContentState {
        ClapsterWidgetAttributes.ContentState(
            countdownSeconds: 0,
            clapTimestamp: Date(),
            clapDescription: ActivityHelpers.getDescription(secondsRemaining: 0, isComplete: true),
            isComplete: true,
            initialDuration: 0
        )
    }
}

// MARK: - Previews
#Preview("Notification", as: .content, using: ClapsterWidgetAttributes.preview) {
   ClapsterWidgetLiveActivity()
} contentStates: {
    ClapsterWidgetAttributes.ContentState.thirtyMinutes
    ClapsterWidgetAttributes.ContentState.oneMinute
    ClapsterWidgetAttributes.ContentState.happening
}

#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: ClapsterWidgetAttributes.preview) {
    ClapsterWidgetLiveActivity()
} contentStates: {
    ClapsterWidgetAttributes.ContentState.thirtyMinutes
    ClapsterWidgetAttributes.ContentState.fiveMinutes
    ClapsterWidgetAttributes.ContentState.oneMinute
    ClapsterWidgetAttributes.ContentState.happening
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: ClapsterWidgetAttributes.preview) {
    ClapsterWidgetLiveActivity()
} contentStates: {
    ClapsterWidgetAttributes.ContentState.thirtyMinutes
    ClapsterWidgetAttributes.ContentState.fiveMinutes
    ClapsterWidgetAttributes.ContentState.happening
}

#Preview("Dynamic Island Minimal", as: .dynamicIsland(.minimal), using: ClapsterWidgetAttributes.preview) {
    ClapsterWidgetLiveActivity()
} contentStates: {
    ClapsterWidgetAttributes.ContentState.thirtyMinutes
    ClapsterWidgetAttributes.ContentState.oneMinute
    ClapsterWidgetAttributes.ContentState.happening
}


