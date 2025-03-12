import SwiftUI

struct GameOverView: View {
    var score: Int
    var finalTier: Int
    var isGameCenterEnabled: Bool
    var resetGameAction: () -> Void
    var showLeaderboardAction: () -> Void
    var backToMenuAction: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Game Over")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    ScoreCardView(
                        score: score,
                        currentTier: finalTier,
                        screenWidth: geometry.size.width
                    )
                    .padding(.horizontal)
                    
                    if finalTier >= DifficultyTiers.count - 1 {
                        Text("Maximum difficulty reached!")
                            .font(.headline)
                            .foregroundColor(.gold)
                            .padding(.top, 5)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.vertical)
                
                Spacer()
                
                VStack(spacing: 16) {
                    PlayAgainButton(action: resetGameAction, width: geometry.size.width * 0.7)
                    
                    if isGameCenterEnabled {
                        LeaderboardButton(action: showLeaderboardAction, width: geometry.size.width * 0.7)
                    }
                    
                    HomeButton(action: backToMenuAction, width: geometry.size.width * 0.7)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct GameOverViewPreviews: PreviewProvider {
    static var previews: some View {
        
        Group {
            // Regular Score
            GameOverView(
                score: 45,
                finalTier: 1,
                isGameCenterEnabled: true,
                resetGameAction: {},
                showLeaderboardAction: {},
                backToMenuAction: {}
            )
            .previewDisplayName("Game Over (Regular Score)")
            
            // Max level reached
            GameOverView(
                score: 150,
                finalTier: 3,
                isGameCenterEnabled: true,
                resetGameAction: {},
                showLeaderboardAction: {},
                backToMenuAction: {}
            )
            .previewDisplayName("Game Over (Max Level)")
            
            // Without Game Center
            GameOverView(
                score: 25,
                finalTier: 1,
                isGameCenterEnabled: false,
                resetGameAction: {},
                showLeaderboardAction: {},
                backToMenuAction: {}
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Game Over (Dark Mode)")
        }
    }
}
