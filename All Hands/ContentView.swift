//
//  ContentView.swift
//  All Hands
//
//  Created by Michael Cavallaro on 3/11/25.
//

import SwiftUI
import UserNotifications

// Define notification category for deep linking
let clapNotificationCategory = "CLAP_EVENT_NOTIFICATION"

struct ContentView: View {
    @State private var notificationsSetup = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            ClapView()
                .tabItem {
                    Label("Clap", systemImage: "hands.clap")
                }
                .tag(1)
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(2)
        }
        .onAppear {
            // Setup automatic notifications once when the app starts
            if !notificationsSetup {
                setupAutomaticNotifications()
            }
            
            // Check if we're launched from a notification
            checkForLaunchNotification()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToClap"))) { _ in
            // Navigate to the Clap tab when notification is received
            selectedTab = 1
        }
        .environmentObject(TabSelection(selection: $selectedTab))
    }
    
    // Check if the app was launched from a notification
    private func checkForLaunchNotification() {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            if let notification = notifications.first {
                if notification.request.content.categoryIdentifier == clapNotificationCategory {
                    DispatchQueue.main.async {
                        // Switch to the Clap tab
                        selectedTab = 1
                    }
                }
            }
        }
    }
    
    // Setup automatic notifications for all upcoming events
    private func setupAutomaticNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    // Configure notification categories for deep linking
                    let clapCategory = UNNotificationCategory(
                        identifier: clapNotificationCategory,
                        actions: [],
                        intentIdentifiers: [],
                        options: [.customDismissAction]
                    )
                    
                    UNUserNotificationCenter.current().setNotificationCategories([clapCategory])
                    
                    // Find all future events and schedule notifications
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(identifier: "MDT")
                    
                    let now = Date()
                    
                    // Get all future dates
                    let futureDates = Dates.compactMap { dateString -> Date? in
                        guard let date = dateFormatter.date(from: dateString) else { return nil }
                        return date > now ? date : nil
                    }.sorted()
                    
                    // Schedule notifications for each event
                    for eventDate in futureDates {
                        // Schedule 1 day before
                        scheduleAutomaticReminder(for: eventDate, minutesBefore: 24 * 60)
                        
                        // Schedule 1 hour before
                        scheduleAutomaticReminder(for: eventDate, minutesBefore: 60)
                        
                        // Schedule 15 minutes before
                        scheduleAutomaticReminder(for: eventDate, minutesBefore: 15)
                    }
                    
                    notificationsSetup = true
                }
            }
        }
    }
    
    // Schedule an automatic reminder without user interaction
    private func scheduleAutomaticReminder(for eventDate: Date, minutesBefore: Int) {
        // Create a unique identifier for this notification
        let identifier = "AutoClap-\(eventDate.timeIntervalSince1970)-\(minutesBefore)"
        
        // Calculate the notification time
        let reminderDate = eventDate.addingTimeInterval(-TimeInterval(minutesBefore * 60))
        
        // Don't schedule if reminder time is in the past
        if reminderDate <= Date() {
            return
        }
        
        // Create date components for the trigger
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: reminderDate
        )
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Clap"
        content.body = "The next clap will happen in \(minutesText(minutesBefore))"
        content.sound = .default
        content.categoryIdentifier = clapNotificationCategory
        
        // Create the trigger using the date components
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // First remove any existing notification with the same ID
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // Then add the notification request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule automatic reminder: \(error.localizedDescription)")
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
}

#Preview {
    ContentView()
}
