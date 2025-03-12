import SwiftUI
import Combine

struct PlayView: View {
    // Game state
    @State private var gameActive = false
    @State private var score = 0
    @State private var gameOver = false
    @State private var handPositions: [HandPosition] = []
    @State private var speed: Double = 2.0 // Seconds per hand
    @State private var handSpawnTimer: Timer.TimerPublisher = Timer.publish(every: 2, on: .main, in: .common)
    @State private var handSpawnCancellable: (any Cancellable)?
    
    // Screen dimensions for calculating random positions
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    @State private var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            
            if !gameActive && !gameOver {
                // Start screen
                VStack {
                    Text("Clap Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text("Tap the hands before they disappear!")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        startGame()
                    }) {
                        Text("Start Game")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            } else if gameOver {
                // Game over screen
                VStack {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding()
                    
                    Text("Your score: \(score)")
                        .font(.title)
                        .padding()
                    
                    Button(action: {
                        resetGame()
                    }) {
                        Text("Play Again")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            } else {
                // Active game - display hands and score
                ForEach(handPositions) { handPosition in
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                        .position(x: handPosition.x, y: handPosition.y)
                        .onTapGesture {
                            tapHand(handPosition)
                        }
                        .transition(.opacity)
                }
                
                // Score display
                VStack {
                    Spacer()
                    Text("Score: \(score)")
                        .font(.title)
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.bottom)
                }
            }
        }
        .onReceive(handSpawnTimer) { _ in
            if gameActive {
                spawnHand()
                checkForMissedHands()
            }
        }
    }
    
    // Start the game
    private func startGame() {
        score = 0
        gameActive = true
        gameOver = false
        speed = 2.0
        handPositions = []
        
        // Start the timer that spawns hands
        handSpawnTimer = Timer.publish(every: 1.5, on: .main, in: .common)
        handSpawnCancellable = handSpawnTimer.connect()
    }
    
    // Reset the game
    private func resetGame() {
        gameOver = false
        startGame()
    }
    
    // Spawn a new hand at a random position
    private func spawnHand() {
        let safeAreaWidth = screenWidth * 0.8
        let safeAreaHeight = screenHeight * 0.7
        
        let randomX = CGFloat.random(in: (screenWidth - safeAreaWidth) / 2...(screenWidth + safeAreaWidth) / 2)
        let randomY = CGFloat.random(in: (screenHeight - safeAreaHeight) / 2...(screenHeight + safeAreaHeight) / 2)
        
        let handPosition = HandPosition(
            id: UUID(),
            x: randomX,
            y: randomY,
            createdAt: Date(),
            timeToLive: speed
        )
        
        withAnimation {
            handPositions.append(handPosition)
        }
    }
    
    // Check for hands that have been on screen too long and remove them
    private func checkForMissedHands() {
        let now = Date()
        
        for hand in handPositions {
            let timeOnScreen = now.timeIntervalSince(hand.createdAt)
            if timeOnScreen > hand.timeToLive {
                // Missed a hand - game over
                endGame()
                return
            }
        }
    }
    
    // Handle tapping on a hand
    private func tapHand(_ hand: HandPosition) {
        if let index = handPositions.firstIndex(where: { $0.id == hand.id }) {
            withAnimation {
                handPositions.remove(at: index)
            }
            
            score += 1
            
            // Increase difficulty
            if score % 5 == 0 && speed > 0.5 {
                speed -= 0.2
                
                // Update timer to spawn hands more frequently
                handSpawnCancellable?.cancel()
                let newInterval = max(0.5, 1.5 - Double(score) / 20)
                handSpawnTimer = Timer.publish(every: newInterval, on: .main, in: .common)
                handSpawnCancellable = handSpawnTimer.connect()
            }
        }
    }
    
    // End the game
    private func endGame() {
        gameActive = false
        gameOver = true
        handSpawnCancellable?.cancel()
        withAnimation {
            handPositions = []
        }
    }
}

// Model for hand positions
struct HandPosition: Identifiable {
    let id: UUID
    let x: CGFloat
    let y: CGFloat
    let createdAt: Date
    let timeToLive: Double
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
    }
}
