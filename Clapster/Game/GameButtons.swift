
import SwiftUI

struct GameButton: View {
    var title: String
    var icon: String
    var iconColor: Color
    var action: () -> Void
    var width: CGFloat? = nil
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.vertical, 14)
            .frame(width: width)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Material.regularMaterial)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), 
                            radius: 2, x: 0, y: 1)
            )
            .foregroundColor(.primary)
        }
    }
}


struct StartGameButton: View {
    var action: () -> Void
    var width: CGFloat? = nil
    
    var body: some View {
        GameButton(
            title: "Start Game",
            icon: "play.fill",
            iconColor: .green,
            action: action,
            width: width
        )
    }
}

struct LeaderboardButton: View {
    var action: () -> Void
    var width: CGFloat? = nil
    
    var body: some View {
        GameButton(
            title: "Leaderboard",
            icon: "trophy.fill",
            iconColor: .yellow,
            action: action,
            width: width
        )
    }
}

struct HomeButton: View {
    var action: () -> Void
    var width: CGFloat? = nil
    
    var body: some View {
        GameButton(
            title: "Back to Menu",
            icon: "house.fill",
            iconColor: .blue,
            action: action,
            width: width
        )
    }
}

struct PlayAgainButton: View {
    var action: () -> Void
    var width: CGFloat? = nil
    
    var body: some View {
        GameButton(
            title: "Play Again",
            icon: "arrow.counterclockwise",
            iconColor: .purple,
            action: action,
            width: width
        )
    }
}


struct GameButtonPreviews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Button Components").font(.headline)
            
            StartGameButton(action: {})
            
            LeaderboardButton(action: {})
            
            HomeButton(action: {})
            
            PlayAgainButton(action: {})
            
            GameButton(
                title: "Custom Button",
                icon: "star.fill",
                iconColor: .pink,
                action: {},
                width: nil
            )
            
            GameButton(
                title: "Secondary Action",
                icon: "gear",
                iconColor: .gray,
                action: {},
                width: nil
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Game Buttons")
        
        VStack(spacing: 20) {
            StartGameButton(action: {})
            LeaderboardButton(action: {})
            HomeButton(action: {})
            PlayAgainButton(action: {})
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Game Buttons (Dark Mode)")
    }
}
