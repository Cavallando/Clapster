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
struct ClapsterApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var tabSelection = TabSelectionViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tabSelection)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        // Check for upcoming claps when app becomes active
                        LiveActivityManager.shared.refreshAllActivities()
                    }
                }
                .onOpenURL { url in
                    handleURL(url)
                }
        }
    }
    
    private func handleURL(_ url: URL) {
        guard url.scheme == "clapster" else { return }
        
        if url.host == "tab" {
            let tabName = url.pathComponents.dropFirst().first
            
            switch tabName {
            case "clap":
                tabSelection.selectedTab = 1
            case "home": 
                tabSelection.selectedTab = 0
            case "about":
                tabSelection.selectedTab = 2
            default:
                break
            }
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

// ViewModel to hold the tab selection state
class TabSelectionViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
}
