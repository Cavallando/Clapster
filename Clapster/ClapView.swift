//
//  ClapView.swift
//  Clapster
//
//  Created by Michael Cavallaro on 3/11/25.
//

import SwiftUI
import UserNotifications
import ConfettiSwiftUI
import Combine  // Add Combine framework import

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
    @State private var timerCancellable: AnyCancellable?  // Use AnyCancellable instead
    @State private var showingReminderAlert = false
    @State private var reminderFeedback = ""
    @State private var showingFeedback = false
    
    // Confetti trigger
    @State private var confettiTrigger = 0
    
    // Add an app state observer
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
                repetitions: 5,
                repetitionInterval: 0.7
            )
            .navigationTitle("Next Clap")
            .onAppear {
                // Recalculate exact time when view appears
                updateNextEvent()
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            // Monitor app state changes
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    // App came to foreground - recalculate exact time
                    updateTimeRemaining()
                    // Restart timer if needed
                    if timerCancellable == nil {
                        startTimer()
                    }
                } else if newPhase == .background {
                    // Optionally stop timer when in background to save resources
                    // stopTimer()
                }
            }
            .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
                updateTimeRemaining()
            }
            .alert("Set Reminder", isPresented: $showingReminderAlert) {
                Button("15 Minutes Before", role: .none) {
                    scheduleReminder(minutesBefore: 15)
                }
                Button("1 Hour Before", role: .none) {
                    scheduleReminder(minutesBefore: 60)
                }
                Button("1 Day Before", role: .none) {
                    scheduleReminder(minutesBefore: 24 * 60)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let nextEvent = nextEventDate {
                    Text("When would you like to be reminded about the clap event on \(formattedEventDate(nextEvent))?")
                } else {
                    Text("No upcoming events to set a reminder for.")
                }
            }
            .alert("Reminder", isPresented: $showingFeedback) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(reminderFeedback)
            }
        }
    }
    
    // Schedule the actual reminder using UserNotifications
    private func scheduleReminder(minutesBefore: Int) {
        guard let eventDate = nextEventDate else {
            reminderFeedback = "No upcoming event to set a reminder for"
            showingFeedback = true
            return
        }
        
        // Create a unique identifier for this notification
        let identifier = "ClapEvent-\(eventDate.timeIntervalSince1970)-\(minutesBefore)"
        
        // Calculate the notification time (event time minus minutes before)
        let reminderDate = eventDate.addingTimeInterval(-TimeInterval(minutesBefore * 60))
        
        // Check if the reminder time is in the past
        if reminderDate <= Date() {
            reminderFeedback = "Cannot set reminder for a time in the past"
            showingFeedback = true
            return
        }
        
        // Create date components for the trigger
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: reminderDate
        )
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Clap Event"
        content.body = "Your clap event is starting in \(minutesText(minutesBefore))"
        content.sound = .default
        
        // Create the trigger using the date components
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Add the notification request
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    reminderFeedback = "Failed to schedule reminder: \(error.localizedDescription)"
                } else {
                    reminderFeedback = "Reminder set for \(minutesText(minutesBefore)) before the event"
                }
                showingFeedback = true
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
            Color(.systemGray6) : // Slightly lighter in dark mode
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

// Use the existing DateTimeCard from HomeView to show event details

#Preview {
    ClapView()
}
