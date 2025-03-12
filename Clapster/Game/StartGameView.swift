import SwiftUI

struct StartGameView: View {
    var isGameCenterEnabled: Bool
    var startGameAction: () -> Void
    var showLeaderboardAction: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            // Main container with vertical center alignment
            VStack(alignment: .center) {
                Spacer()
                
                // Game title and instructions - centered group
                VStack(spacing: 20) {
                    Text("Clapster: The Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Tap the hands before they disappear!")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)
                    
                    // Game instructions
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.orange)
                            Text("Tap the hands before they disappear")
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "speedometer")
                                .foregroundColor(.orange)
                            Text("Hands appear faster and faster")
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "arrow.up.forward")
                                .foregroundColor(.green)
                            Text("See how high you can go")
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                            Text("Miss one hand and it's game over!")
                        }
                    }
                    .padding()
                }
                .padding()
                
                Spacer()
                
                // Buttons at bottom
                VStack(spacing: 16) {
                    StartGameButton(action: startGameAction, width: geometry.size.width * 0.7)
                    
                    if isGameCenterEnabled {
                        LeaderboardButton(action: showLeaderboardAction, width: geometry.size.width * 0.7)
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// Preview for ScoreCardView
struct ScoreCardViewPreviews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Low score
            ScoreCardView(score: 5, currentTier: 0, screenWidth: 390)
            
            // Medium score
            ScoreCardView(score: 30, currentTier: 1, screenWidth: 390)
            
            // High score
            ScoreCardView(score: 120, currentTier: 3, screenWidth: 390)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Score Cards")
        
        // Dark mode preview
        ScoreCardView(score: 85, currentTier: 2, screenWidth: 390)
            .padding()
            .background(Color.black)
            .previewLayout(.sizeThatFits)
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Score Card (Dark Mode)")
    }
}

// Preview for StartGameView
struct StartGameViewPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            // With Game Center enabled
            StartGameView(
                isGameCenterEnabled: true,
                startGameAction: {},
                showLeaderboardAction: {}
            )
            .previewDisplayName("Start Screen (Game Center Enabled)")
            
            // Without Game Center
            StartGameView(
                isGameCenterEnabled: false,
                startGameAction: {},
                showLeaderboardAction: {}
            )
            .previewDisplayName("Start Screen (No Game Center)")
            
            // Dark mode
            StartGameView(
                isGameCenterEnabled: true,
                startGameAction: {},
                showLeaderboardAction: {}
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Start Screen (Dark Mode)")
        }
    }
}
