import SwiftUI
import Combine
import GameKit

// Game constants and difficulty settings
let DEFAULT_SPEED = 2.0
let DEFAULT_SPAWN_RATE = 2.0


struct PlayView: View {
    @EnvironmentObject private var gameState: GameStateManager
    
    @State private var isGameCenterEnabled = false
    @State private var gameCenterError: String? = nil
    @State private var showGameCenterAlert = false
    @State private var tierChangeColor = Color.white.opacity(0)
    
    // Color management
    private let handColors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .yellow]
    @State private var lastUsedColorIndex: Int? = nil
    
    // Game Center state
    @State private var leaderboardID = "fun.mike.clapster.leaderboard"
    
    // Constants for layout
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    @State private var screenHeight: CGFloat = UIScreen.main.bounds.height
    private let handSize: CGFloat = 50
    private let bottomScoreHeight: CGFloat = 100
    private let topPadding: CGFloat = 60
    private let tabBarHeight: CGFloat = 49 // Standard iOS TabView height
    
    // Store the final tier when game ends
    @State private var finalTier = 0
    
    // Haptic feedback generators
    private let tapHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let successHaptic = UINotificationFeedbackGenerator()
    
    @State private var showStartScreen = true
    
    init(preventAutoStart: Bool = false) {}
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {      
                // Content area
                if !gameState.isGameActive && !gameState.isGameOver {
                    // Start screen
                    StartGameView(
                        isGameCenterEnabled: isGameCenterEnabled,
                        startGameAction: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameState.startGame()
                            }
                        },
                        showLeaderboardAction: showLeaderboard
                    )
                } 
                else if gameState.isGameOver {
                    // Game over screen with transition
                    GameOverView(
                        score: gameState.score,
                        finalTier: gameState.currentTier, 
                        isGameCenterEnabled: isGameCenterEnabled,
                        resetGameAction: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameState.startGame()
                            }
                        },
                        showLeaderboardAction: showLeaderboard,
                        backToMenuAction: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameState.goToMenu()
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9).combined(with: .offset(y: 20))),
                        removal: .opacity.combined(with: .scale(scale: 0.9))
                    ))
                }
                else {
                    // Active gameplay with transition
                    VStack(spacing: 0) {
                      
                        ScoreCardView(
                            score: gameState.score,
                            currentTier: gameState.currentTier,
                            screenWidth: geometry.size.width
                        )
                        .padding(.bottom, 10)
                        
                        // Game play area
                        ZStack {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: geometry.size.width, height: geometry.size.height - 130)
                                .contentShape(Rectangle())
                                // Disable hit testing on the entire game area
                                .allowsHitTesting(false)
                            
                            ForEach(gameState.handPositions) { hand in
                                HandView(hand: hand, tapAction: {
                                    tapHand(hand)
                                })
                                .position(x: hand.x, y: hand.y)
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height - 130)
                        .onAppear {
                            gameState.updateScreenDimensions(
                                width: geometry.size.width,
                                height: geometry.size.height - 100
                            )
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 1.1)),
                        removal: .opacity.combined(with: .scale(scale: 0.9))
                    ))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: gameState.isGameActive)
            .animation(.easeInOut(duration: 0.3), value: gameState.isGameOver)
            .onAppear {
                authenticatePlayer()
            }
        }
    }
    
    private func tapHand(_ hand: HandPosition) {
        // Trigger haptic feedback
        tapHaptic.impactOccurred()
        
        // Play tap sound
        SoundManager.shared.playSound(named: "clap", fileExtension: "wav")
        // If you don't have custom sounds, use system sound as fallback:
        // SoundManager.shared.playSystemSound()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            gameState.tapHand(hand)
        }
        
        if gameState.isGameOver && isGameCenterEnabled {
            submitScore(gameState.score)
        }
    }
    
    // MARK: - Game Center methods
    
    private func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let error = error {
                self.gameCenterError = "Authentication error: \(error.localizedDescription)"
                print("Game Center authentication error: \(error.localizedDescription)")
                return
            }
            
            if let viewController = viewController {
                // Present the view controller if needed
                if let window = UIApplication.shared.windows.first, 
                   let rootViewController = window.rootViewController {
                    rootViewController.present(viewController, animated: true)
                }
            } else if GKLocalPlayer.local.isAuthenticated {
                // Player is authenticated
                self.isGameCenterEnabled = true
                print("Game Center: Successfully authenticated as \(GKLocalPlayer.local.displayName)")
                
                // Verify leaderboard exists
                verifyLeaderboard()
            } else {
                // Player declined to sign in
                self.isGameCenterEnabled = false
                self.gameCenterError = "You must sign in to Game Center to use leaderboards"
                print("Game Center: Player declined to sign in")
            }
        }
    }
    
    private func verifyLeaderboard() {
        print("Verifying Game Center leaderboard with ID: \(leaderboardID)")
        GKLeaderboard.loadLeaderboards(IDs: [leaderboardID]) { leaderboards, error in
            if let error = error {
                print("Error loading leaderboard: \(error.localizedDescription)")
                self.gameCenterError = "Error loading leaderboard: \(error.localizedDescription)"
                return
            }
            
            if leaderboards?.count == 0 {
                print("Leaderboard \(self.leaderboardID) not found!")
                self.gameCenterError = "Leaderboard not found. Check your App Store Connect configuration."
            } else {
                print("Leaderboard verified successfully!")
                submitTestScore()
            }
        }
    }
    
    private func submitTestScore() {
        GKLeaderboard.submitScore(1, context: 0, player: GKLocalPlayer.local,
                                 leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("Error submitting test score: \(error.localizedDescription)")
            } else {
                print("Test score submitted successfully")
            }
        }
    }
    
    private func submitScore(_ score: Int) {
        print("Submitting score \(score) to leaderboard ID: \(leaderboardID)")
        
        GKLeaderboard.submitScore(Int(score), context: 0, player: GKLocalPlayer.local,
                                 leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("Error submitting score: \(error.localizedDescription)")
            } else {
                print("Score \(score) submitted successfully")
            }
        }
    }
    
    private func showLeaderboard() {
        print("Showing Game Center leaderboard...")
        let gcViewController = GKGameCenterViewController(state: .leaderboards)
        gcViewController.leaderboardIdentifier = leaderboardID
        gcViewController.gameCenterDelegate = GameCenterDelegate.shared
        
        if let window = UIApplication.shared.windows.first, 
           let rootViewController = window.rootViewController {
            rootViewController.present(gcViewController, animated: true)
        }
    }
}

// Game Center Delegate
class GameCenterDelegate: NSObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterDelegate()
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

// MARK: - Preview Providers

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
    }
}

