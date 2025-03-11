//
//  ClapsterApp.swift
//  Clapster
//
//  Created by Michael Cavallaro on 3/11/25.
//

import SwiftUI
import UserNotifications

// Environment object to share selected tab across the app
class TabSelection: ObservableObject {
    init(selection: Binding<Int>) {
        self._selection = selection
    }
    
    private var _selection: Binding<Int>
    
    func select(tab: Int) {
        _selection.wrappedValue = tab
    }
}

@main
struct All_HandsApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set delegate to handle notifications while app is in foreground or when opened from a notification
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification banner even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    // Handle notification tap when app is in background or closed
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Check if this is our clap notification
        if response.notification.request.content.categoryIdentifier == clapNotificationCategory {
            // Use NotificationCenter to broadcast the navigation request
            // This will be picked up by ContentView
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToClap"), object: nil)
        }
        
        completionHandler()
    }
}
