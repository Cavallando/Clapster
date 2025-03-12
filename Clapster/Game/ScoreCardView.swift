import SwiftUI

struct ScoreCardView: View {
    var score: Int
    var currentTier: Int
    var screenWidth: CGFloat
    
    @EnvironmentObject private var gameState: GameStateManager
    @Environment(\.colorScheme) var colorScheme
    
    // Add state for the animation scale
    @State private var difficultyTextScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Score and tier tracker container
            HStack(spacing: 0) {
                // Score display
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Text("\(score)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(minWidth: 100, alignment: .leading)
                .padding(.leading)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("DIFFICULTY")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Text(DifficultyTiers[currentTier].name)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(DifficultyTiers[currentTier].color)
                        .scaleEffect(difficultyTextScale)
                        .animation(.interpolatingSpring(stiffness: 170, damping: 8), value: difficultyTextScale)
                }
                .frame(minWidth: 100, alignment: .trailing)
                .padding(.trailing)
            }
            .padding(.vertical, 12)
            .frame(width: screenWidth * 0.95)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Material.regularMaterial)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.2), 
                            radius: 4, x: 0, y: 2)
            )
        }
        // Listen for changes to the animation flag
        .onChange(of: gameState.animateDifficultyChange) { newValue in
            if newValue {
                // Animate difficulty text
                withAnimation(.easeInOut(duration: 0.15)) {
                    difficultyTextScale = 1.3
                }
                
                // Return to normal size after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        difficultyTextScale = 1.0
                    }
                }
            }
        }
    }
}