import SwiftUI
struct HandView: View {
    let hand: HandPosition
    let tapAction: () -> Void
    
    var body: some View {
        Image(systemName: "hand.raised.fill")
            .font(.system(size: 50))
            .foregroundColor(hand.color)
            .background(
                // Create a completely invisible touch target that's slightly larger
                // than the visible hand but still matches its shape
                Circle()
                    .fill(Color.clear)
                    .frame(width: 60, height: 60)
            )
            .contentShape(Circle())
            .onTapGesture {
                tapAction()
            }
            // Debug: uncomment to see tap area
            // .overlay(Circle().stroke(Color.white, lineWidth: 1))
    }
} 
