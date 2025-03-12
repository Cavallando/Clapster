import SwiftUI
import ActivityKit
import WidgetKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private init() {}
    
    // Check for upcoming claps and start Live Activities if needed
    func checkAndStartLiveActivities() {
        // Get the next clap from ClapEventData
        guard let nextClap = ClapEventData.first else {
            print("No upcoming claps found")
            return
        }
        
        // Calculate how soon the clap is
        let secondsUntilClap = Int(nextClap.timeIntervalSince(Date()))
        
        // Check if the clap is today (within the next 8 hours - iOS limit for initial Live Activities)
        // You can adjust the time window as needed
        if secondsUntilClap > 0 && secondsUntilClap <= 8 * 60 * 60 {
            // Check if we already have an active Live Activity for this clap
            if !hasActiveActivityForClap(at: nextClap) {
                startLiveActivity(for: nextClap)
            }
        }
    }
    
    // Check if we already have an active Live Activity for this clap time
    private func hasActiveActivityForClap(at clapTime: Date) -> Bool {
        // Check all running activities
        for activity in Activity<ClapsterWidgetAttributes>.activities {
            // Get the timestamp from the activity
            if let activityTimestamp = try? activity.contentState.clapTimestamp, 
               abs(activityTimestamp.timeIntervalSince(clapTime)) < 5 { // Within 5 seconds tolerance
                return true // Already have an activity for this clap
            }
        }
        return false
    }
    
    // Start a Live Activity for the given clap time
    func startLiveActivity(for clapTime: Date) {
        // Check if Live Activities are supported
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities not enabled")
            return
        }
        
        // Calculate seconds until clap more precisely
        let secondsUntilClap = max(0, Int(clapTime.timeIntervalSince(Date())))
        
        // Only start activity if clap is within 8 hours
        guard secondsUntilClap > 0 && secondsUntilClap <= 8 * 60 * 60 else {
            print("Clap is too far in the future for a Live Activity")
            return
        }
        
        // Create description based on time until clap
        let description: String
        if secondsUntilClap <= 5 * 60 { // 5 minutes or less
            description = "Get ready to clap very soon!"
        } else if secondsUntilClap <= 30 * 60 { // 30 minutes or less
            description = "The clap is coming up shortly!"
        } else {
            description = "We clapping today!"
        }
        
        // Create the activity attributes
        let attributes = ClapsterWidgetAttributes(name: "Next Clap")
        
        // Create the initial content state
        let initialDuration = calculateMaxDuration(secondsUntilEvent: secondsUntilClap)
        let contentState = ClapsterWidgetAttributes.ContentState(
            countdownSeconds: secondsUntilClap,
            clapTimestamp: clapTime,
            clapDescription: description,
            isComplete: false,
            initialDuration: initialDuration
        )
        
        // Start the activity
        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            print("Started Live Activity with ID: \(activity.id)")
            
            // Set up regular updates
            startRegularUpdates(for: activity.id, clapTime: clapTime)
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }
    
    // End a Live Activity
    func endLiveActivity(id: String, showCompletionState: Bool = true) {
        // Create a completely separate method to avoid closure issues
        Task { 
            await endLiveActivityAsync(id: id, showCompletionState: showCompletionState)
        }
    }
    
    // Separate async method to handle the ending logic
    private func endLiveActivityAsync(id: String, showCompletionState: Bool) async {
        do {
            for activity in Activity<ClapsterWidgetAttributes>.activities {
                if activity.id == id {
                    if showCompletionState {
                        // First update to "CLAP NOW" state
                        let finalState = ClapsterWidgetAttributes.ContentState(
                            countdownSeconds: 0,
                            clapTimestamp: Date(),
                            clapDescription: "Clap! Clap! Clap!",
                            isComplete: true,
                            initialDuration: 1
                        )
                        
                        await activity.update(using: finalState)
                        
                        // End after a delay
                        try await Task.sleep(nanoseconds: 30 * 1_000_000_000)
                    }
                    
                    // End the activity
                    await activity.end(dismissalPolicy: .after(Date().addingTimeInterval(180))) // End after 3 minutes
                    break
                }
            }
        } catch {
            print("Error ending live activity: \(error)")
        }
    }
    
    // Set up a timer to regularly update the Live Activity
    private func startRegularUpdates(for activityId: String, clapTime: Date) {
        // Launch a separate task without closures
        Task {
            await startRegularUpdatesAsync(for: activityId, clapTime: clapTime)
        }
    }
    
    // Separate async method to handle updates
    private func startRegularUpdatesAsync(for activityId: String, clapTime: Date) async {
        do {
            // Update at the most frequent interval possible until the clap time
            while Date() < clapTime {
                let secondsRemaining = Int(clapTime.timeIntervalSince(Date()))
                if secondsRemaining <= 0 {
                    // Time to clap!
                    await updateLiveActivityAsync(id: activityId, secondsRemaining: 0, isComplete: true)
                    
                    // End the activity after the clap
                    await endLiveActivityAsync(id: activityId, showCompletionState: true)
                    break
                } else {
                    // Update countdown - ALWAYS update every second for a smooth countdown
                    await updateLiveActivityAsync(id: activityId, secondsRemaining: secondsRemaining)
                    
                    // Always sleep for 1 second to ensure we update every second
                    try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                }
            }
        } catch {
            print("Error in regular updates: \(error)")
        }
    }
    
    // Update method - also converted to avoid closures
    func updateLiveActivity(id: String, secondsRemaining: Int, isComplete: Bool = false) {
        Task {
            await updateLiveActivityAsync(id: id, secondsRemaining: secondsRemaining, isComplete: isComplete)
        }
    }
    
    // Async implementation of update
    private func updateLiveActivityAsync(id: String, secondsRemaining: Int, isComplete: Bool = false) async {
        // Use the shared helper instead of duplicating code
        let description = ActivityHelpers.getDescription(secondsRemaining: secondsRemaining, isComplete: isComplete)
        
        // IMPORTANT: Use the actual timestamp for clapTimestamp
        // instead of calculating it from secondsRemaining
        let updatedState = ClapsterWidgetAttributes.ContentState(
            countdownSeconds: secondsRemaining,
            clapTimestamp: ClapEventData.first ?? Date().addingTimeInterval(TimeInterval(secondsRemaining)),
            clapDescription: description,
            isComplete: isComplete,
            initialDuration: calculateMaxDuration(secondsUntilEvent: secondsRemaining)
        )
        
        // Find the activity by ID
        for activity in Activity<ClapsterWidgetAttributes>.activities {
            if activity.id == id {
                do {
                    let startTime = Date()
                    await activity.update(using: updatedState)
                    let updateTime = Date().timeIntervalSince(startTime)
                    print("Live Activity updated: \(secondsRemaining) seconds remaining (update took \(String(format: "%.4f", updateTime))s)")
                } catch {
                    print("Error updating Live Activity: \(error)")
                }
                break
            }
        }
    }
    
    // Call this to manage all activities (start new ones, update existing ones)
    func refreshAllActivities() {
        // Start activities for upcoming claps
        checkAndStartLiveActivities()
        
        // End any outdated activities
        cleanupOutdatedActivities()
    }
    
    // End activities for claps that have already passed
    private func cleanupOutdatedActivities() {
        for activity in Activity<ClapsterWidgetAttributes>.activities {
            if let timestamp = try? activity.contentState.clapTimestamp,
               timestamp < Date().addingTimeInterval(-5 * 60) { // 5 minutes past clap time
                Task {
                    await activity.end(dismissalPolicy: .immediate)
                }
            }
        }
    }
    
    // Add this helper
    private func calculateMaxDuration(secondsUntilEvent: Int) -> Int {
        if secondsUntilEvent <= 5 * 60 { // 5 minutes
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
