//
//  ClapView.swift
//  Clapster
//
//  Created by Michael Cavallaro on 3/11/25.
//

import SwiftUI
import UserNotifications
import ConfettiSwiftUI
import Combine

struct ConfettiEmoji: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var scale: CGFloat
    var speed: CGFloat
    var xMovement: CGFloat
}

struct ClapView: View {
    @State private var timeRemaining: TimeInterval = 0
    @State private var nextEventDate: Date?
    @State private var timerCancellable: AnyCancellable?
    
    @State private var confettiTrigger = 0
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        if let nextEvent = nextEventDate {
                            // Event details at the top
                            DateTimeCard(date: nextEvent)
                                .padding(.horizontal)
                                .padding(.top, 10)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // Countdown section centered
                            VStack(spacing: 15) {
                                HStack(spacing: 8) {
                                    CountdownBlock(value: days, unit: "DAYS")
                                    CountdownBlock(value: hours, unit: "HOURS")
                                    CountdownBlock(value: minutes, unit: "MINS")
                                    CountdownBlock(value: seconds, unit: "SECS")
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.vertical)
                            
                            // Add extra padding at the bottom for the fixed button
                            Spacer(minLength: 80)
                        } else {
                            ContentUnavailableView(
                                "No Upcoming Events",
                                systemImage: "calendar.badge.exclamationmark",
                                description: Text("All scheduled clap events have already passed.")
                            )
                            .padding(.top, 50)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .confettiCannon(
                trigger: $confettiTrigger,
                num: 30,
                confettis: [.text("👏")],
                confettiSize: 30,
                openingAngle: Angle(degrees: 0),
                closingAngle: Angle(degrees: 360),
                radius: 200,
                repetitions: 3,
                repetitionInterval: 0.7
            )
            .navigationTitle("Next Clap")
            .onAppear {
                updateNextEvent()
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            // Monitor app state changes
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    updateTimeRemaining()
                    if timerCancellable == nil {
                        startTimer()
                    }
                } else if newPhase == .background {
                    stopTimer()
                }
            }
            .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
                updateTimeRemaining()
            }
        }
    }
    
    // Helper to format the minutes text for user feedback
    private func minutesText(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) minutes"
        } else if minutes == 60 {
            return "1 hour"
        } else if minutes == 24 * 60 {
            return "1 day"
        } else {
            let hours = minutes / 60
            return "\(hours) hours"
        }
    }
    
    // Format the event date for the alert message
    private func formattedEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private var days: Int {
        return Int(timeRemaining) / (24 * 3600)
    }
    
    private var hours: Int {
        return (Int(timeRemaining) % (24 * 3600)) / 3600
    }
    
    private var minutes: Int {
        return (Int(timeRemaining) % 3600) / 60
    }
    
    private var seconds: Int {
        return Int(timeRemaining) % 60
    }
    
    private func updateNextEvent() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "MDT")
        
        let now = Date()
        
        // Find the next upcoming event
        let futureDates = Dates.compactMap { dateString -> Date? in
            guard let date = dateFormatter.date(from: dateString) else {
                return nil
            }
            return date > now ? date : nil
        }.sorted()
        
        if let nextDate = futureDates.first {
            nextEventDate = nextDate
            updateTimeRemaining()
        } else {
            nextEventDate = nil
            timeRemaining = 0
        }
    }
    
    private func updateTimeRemaining() {
        guard let nextEvent = nextEventDate else {
            timeRemaining = 0
            return
        }
        
        // Get the exact current time for accurate calculation
        let now = Date()
        let oldTimeRemaining = timeRemaining
        
        // Calculate exact time remaining
        timeRemaining = nextEvent.timeIntervalSince(now)
        
        // Trigger confetti if we just crossed the threshold
        if oldTimeRemaining > 0 && timeRemaining <= 0 {
            confettiTrigger += 1
            
            // Find the next event after a small delay to allow confetti to show
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                updateNextEvent()
            }
        }
        
        if timeRemaining < 0 {
            timeRemaining = 0
        }
    }
    
    private func startTimer() {
        // Remove any existing timer
        stopTimer()
        
        // Create a timer publisher (without weak self since this is a struct)
        timerCancellable = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                updateTimeRemaining()
            }
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}

struct CountdownBlock: View {
    let value: Int
    let unit: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.primary)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: true, vertical: false)
        }
        .frame(width: 75, height: 65)
        .padding(.vertical, 6)
        .padding(.horizontal, 3)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(blockBackgroundColor)
                .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor, lineWidth: 0.5)
                )
        )
    }
    
    // Dynamic block background color based on color scheme
    private var blockBackgroundColor: Color {
        colorScheme == .dark ? 
            Color(.systemGray6) :
            Color(.systemBackground)
    }
    
    // Dynamic shadow color based on color scheme
    private var shadowColor: Color {
        colorScheme == .dark ?
            Color.black.opacity(0.3) :
            Color.black.opacity(0.2)
    }
    
    // Subtle border color for better definition in dark mode
    private var borderColor: Color {
        colorScheme == .dark ?
            Color.gray.opacity(0.3) :
            Color.clear
    }
}

#Preview {
    ClapView()
}
