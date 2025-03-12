//
//  ClapsterWidget.swift
//  ClapsterWidget
//
//  Created by Michael Cavallaro on 3/11/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(), 
            configuration: ConfigurationAppIntent(),
            nextClapTime: Date().addingTimeInterval(3600) // 1 hour
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let nextClap = await getNextClap()
        return SimpleEntry(
            date: Date(), 
            configuration: configuration,
            nextClapTime: nextClap
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        // Fetch the next clap information
        let nextClap = await getNextClap()
        
        // Create the current entry
        let currentEntry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            nextClapTime: nextClap
        )
        entries.append(currentEntry)
        
        // If we have a next clap time, add an entry for that time
        if let nextTime = nextClap {
            // Add an entry for when the clap happens
            let clapEntry = SimpleEntry(
                date: nextTime,
                configuration: configuration,
                nextClapTime: nextTime
            )
            entries.append(clapEntry)
            
            // Add an entry for just after the clap to update to the next one
            let afterClapEntry = SimpleEntry(
                date: nextTime.addingTimeInterval(1),
                configuration: configuration,
                nextClapTime: nil // We'll need to fetch the next one
            )
            entries.append(afterClapEntry)
            
            return Timeline(entries: entries, policy: .after(nextTime.addingTimeInterval(1)))
        }
        
        // If no next clap, refresh in an hour
        return Timeline(entries: entries, policy: .after(Date().addingTimeInterval(3600)))
    }
    
    private func getNextClap() async -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: OG_TZ)
        
        guard let nextClap = ClapEventData.first else {
            return nil
        }
        
        let localDateFormatter = DateFormatter()
        localDateFormatter.dateStyle = .medium
        
        return nextClap
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let nextClapTime: Date?
}

struct ClapsterWidgetEntryView : View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    // Define your brand color
    let brandColor = Color(hex: "#5321A8")
    
    var body: some View {
        ZStack {
            // Background
            if (widgetFamily != .accessoryCircular && widgetFamily != .accessoryRectangular && widgetFamily != .accessoryInline) {
                brandColor
                    .opacity(colorScheme == .dark ? 0.9 : 0.85)
            }
            
            // Content based on widget size
            switch widgetFamily {
            case .systemSmall:
                smallWidgetLayout
            case .systemMedium:
                mediumWidgetLayout
            case .systemLarge:
                largeWidgetLayout
            case .accessoryCircular, .accessoryRectangular, .accessoryInline:
                lockScreenLayout
            default:
                smallWidgetLayout
            }
        }.containerBackground(for: .widget) {
            Color(hex: "#5321A8")
        }
    }
    
    // Small widget layout (original layout)
    private var smallWidgetLayout: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let nextClapTime = entry.nextClapTime {
                let (number, unit) = extractCountdownComponents(nextClapTime)
                
                Text("Next Clap")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(number)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                    
                    Text(unit)
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                }
                .padding(.vertical, 4)
            } else {
                Text("We did it!!")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("👏👏")
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
    
    // Medium widget with more information
    private var mediumWidgetLayout: some View {
        HStack(alignment: .center, spacing: 0) {
            // Left side with countdown
            VStack(alignment: .leading, spacing: 4) {
                if let nextClapTime = entry.nextClapTime {
                    let (number, unit) = extractCountdownComponents(nextClapTime)
                    
                    Text("Next Clap")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(number)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        
                        Text(unit)
                            .font(.system(size: 26, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.vertical, 4)
                } else {
                    Text("We did it!!")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("👏👏👏")
                        .font(.system(size: 42, weight: .medium, design: .rounded))
                        .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
            
            // Right side with exact time
            if let nextClapTime = entry.nextClapTime {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(nextClapTime, style: .time)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(nextClapTime, style: .date)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .padding()
            }
        }
    }
    
    // Large widget with more information and visuals
    private var largeWidgetLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let nextClapTime = entry.nextClapTime {
                let (number, unit) = extractCountdownComponents(nextClapTime)
                
                // Top section - main countdown
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Clap In")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Text(number)
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.7)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        
                        Text(unit)
                            .font(.system(size: 32, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Bottom section - exact time
                HStack {
                    VStack(alignment: .leading) {
                        Text(nextClapTime, style: .time)
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(nextClapTime, style: .date)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Visual indicator
                    VStack {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Get Ready!")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.top, 16)
            } else {
                // No claps - celebration view
                VStack(spacing: 12) {
                    Text("We did it!!")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("👏👏👏")
                        .font(.system(size: 80))
                        .padding(.vertical)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
    
    // Lock screen widget layout (minimal)
    private var lockScreenLayout: some View {
        ZStack {
            if widgetFamily == .accessoryCircular {
                // Circular layout (clock-like)
                accessoryCircularLayout
            } else {
                // Rectangular or inline
                accessoryRectangularLayout
            }
        }
    }
    
    private var accessoryCircularLayout: some View {
        ZStack {
            if let nextClapTime = entry.nextClapTime {
                let (number, _) = extractCountdownComponents(nextClapTime)
                
                VStack(spacing: 2) {
                    HStack(spacing: 1) {
                        Text(number)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .minimumScaleFactor(0.6)
                    
                        Text(shortUnitFor(nextClapTime))
                            .font(.system(size: 9))
                            .padding(.leading, -1)
                    }
                    
                    Text("Next Clap")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
                .padding(2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("👏")
                    .font(.system(size: 22))
                    .padding(4)
            }
        }
    }
    
    private var accessoryRectangularLayout: some View {
        HStack(spacing: 4) {
            if let nextClapTime = entry.nextClapTime {
                let (number, _) = extractCountdownComponents(nextClapTime)
                
                Image(systemName: "hand.raised.fill")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text("Clap in \(number) \(shortUnitFor(nextClapTime))")
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundColor(.primary)
            } else {
                Text("👏")
                    .font(.system(.body, design: .rounded))
                    .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    // Helper for shortened units on lock screen
    private func shortUnitFor(_ date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: date)
        
        if let days = components.day, days > 0 {
            return "d"
        } else if let hours = components.hour, hours > 0 {
            return "h"
        } else {
            return "m"
        }
    }
    
    // Original helper functions
    private func extractCountdownComponents(_ clapTime: Date) -> (String, String) {
        let now = Date()
        if clapTime < now {
            return ("Now", "Clap!!")
        }
        
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: clapTime)
        
        if let days = components.day, let hours = components.hour, let minutes = components.minute {
            if days > 0 {
                return ("\(days)", "day\(days == 1 ? "" : "s")")
            } else if hours > 0 {
                return ("\(hours)", "hour\(hours == 1 ? "" : "s")")
            } else if minutes > 0 {
                return ("\(minutes)", "minute\(minutes == 1 ? "" : "s")")
            } else {
                return ("< 1", "minute")
            }
        }
        
        return ("Soon", "")
    }
}

struct ClapsterWidget: Widget {
    let kind: String = "ClapsterWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            ClapsterWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(hex: "#5321A8")
                }
        }
        .contentMarginsDisabled()
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

// MARK: - PreviewProvider
struct ClapsterWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Small widget preview - 30 minutes
            ClapsterWidgetEntryView(entry: SimpleEntry(
                date: .now,
                configuration: ConfigurationAppIntent(),
                nextClapTime: Date().addingTimeInterval(30 * 60)
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small Widget - 30 Minutes")
            
            // Medium widget preview - 2 hours
            ClapsterWidgetEntryView(entry: SimpleEntry(
                date: .now,
                configuration: ConfigurationAppIntent(),
                nextClapTime: Date().addingTimeInterval(2 * 60 * 60)
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium Widget - 2 Hours")
            
            // Large widget preview - 2 days
            ClapsterWidgetEntryView(entry: SimpleEntry(
                date: .now,
                configuration: ConfigurationAppIntent(),
                nextClapTime: Date().addingTimeInterval(2 * 24 * 60 * 60)
            ))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .previewDisplayName("Large Widget - 2 Days")
            
            // No more claps preview
            ClapsterWidgetEntryView(entry: SimpleEntry(
                date: .now,
                configuration: ConfigurationAppIntent(),
                nextClapTime: nil
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("No More Claps")
            
            // Circular lock screen widget
            ClapsterWidgetEntryView(entry: SimpleEntry(
                date: .now,
                configuration: ConfigurationAppIntent(),
                nextClapTime: Date().addingTimeInterval(30 * 60)
            ))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Lock Screen - Circular")
            
            // Rectangular lock screen widget
            ClapsterWidgetEntryView(entry: SimpleEntry(
                date: .now,
                configuration: ConfigurationAppIntent(),
                nextClapTime: Date().addingTimeInterval(2 * 60)
            ))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Lock Screen - Rectangular")
        }
    }
}
