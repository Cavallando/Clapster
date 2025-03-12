import SwiftUI
import Combine
import GameKit

// Game constants and difficulty settings
let DEFAULT_SPEED = 2.0


struct PlayView: View {
    @EnvironmentObject private var gameState: GameStateManager
    
    @State private var showGameCenterAlert = false
    @State private var tierChangeColor = Color.white.opacity(0)
    
    // Color management
    private let handColors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .yellow]
    @State private var lastUsedColorIndex: Int? = nil
    
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
                        isGameCenterEnabled: gameState.isGameCenterEnabled,
                        startGameAction: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameState.startGame()
                            }
                        },
                        showLeaderboardAction: gameState.showLeaderboard
                    )
                } 
                else if gameState.isGameOver {
                    // Game over screen with transition
                    GameOverView(
                        score: gameState.score,
                        finalTier: gameState.currentTier,
                        gameOverReason: gameState.gameOverReason,
                        isGameCenterEnabled: gameState.isGameCenterEnabled,
                        resetGameAction: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                gameState.startGame()
                            }
                        },
                        showLeaderboardAction: gameState.showLeaderboard,
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
                            // Background area that will trigger game over if tapped
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: geometry.size.width, height: geometry.size.height - 130)
                                .contentShape(Rectangle())
                                // Enable hit testing to detect taps on background
                                .allowsHitTesting(true)
                                .onTapGesture {
                                    // Vibrate to indicate mistake
                                    let errorHaptic = UINotificationFeedbackGenerator()
                                    errorHaptic.notificationOccurred(.error)
                                    
                                    // End the game with reason
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        gameState.endGame(reason: .tappedOutside)
                                    }
                                    
                                    // Submit score if game center is enabled
                                    if gameState.isGameCenterEnabled {
                                        gameState.submitScore(gameState.score)
                                    }
                                }
                            
                            // Hands must be rendered on top of the background
                            ForEach(gameState.handPositions) { hand in
                                HandView(hand: hand, tapAction: {
                                    tapHand(hand)
                                })
                                .position(x: hand.x, y: hand.y)
                                // Make sure hands have higher Z index to receive taps first
                                .zIndex(10)
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
                gameState.initializeGameCenter()
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
        
        if gameState.isGameOver && gameState.isGameCenterEnabled {
            gameState.submitScore(gameState.score)
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

