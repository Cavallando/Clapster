import SwiftUI

struct StartGameView: View {
    var isGameCenterEnabled: Bool
    var startGameAction: () -> Void
    var showLeaderboardAction: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                Text("Clapster: The Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Tap the hands before they disappear!")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 5)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "speedometer")
                            .foregroundColor(.blue)
                        Text("Hands appear and disappear faster as you advance")
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.orange)
                        Text("Multiple hands may appear at once in higher tiers")
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "arrow.up.forward")
                            .foregroundColor(.green)
                        Text("Reach higher tiers by increasing your score")
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text("Miss one hand and it's game over!")
                    }
                }
                .padding()
                
                Spacer()
                
                VStack(spacing: 16) {
                    StartGameButton(action: startGameAction, width: geometry.size.width * 0.7)
                    
                    if isGameCenterEnabled {
                        LeaderboardButton(action: showLeaderboardAction, width: geometry.size.width * 0.7)
                    }
                }
                .padding(.bottom, 40)
            }
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
