import SwiftUI

struct ScoreCardView: View {
    var score: Int
    var currentTier: Int
    var screenWidth: CGFloat
    
    @Environment(\.colorScheme) var colorScheme
    
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
    }
}