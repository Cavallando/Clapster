import SwiftUI
import Combine

class GameStateManager: ObservableObject {
    // Display state
    @Published var isGameActive = false
    @Published var isGameOver = false
    
    // Game metrics
    @Published var score: Int = 0
    @Published var currentTier: Int = 0
    @Published var handPositions: [HandPosition] = []
    
    // Game settings
    @Published var screenDimensions: CGSize = CGSize(width: UIScreen.main.bounds.width, 
                                                    height: UIScreen.main.bounds.height)
    
    // Size constants
    let handSize: CGFloat = 50
    
    // Timer
    private var gameTimer: Timer?
    private var currentSpeed: Double = DEFAULT_SPEED
    private var currentSpawnRate: Double = DEFAULT_SPAWN_RATE

    // Add a flag to trigger the difficulty label animation
    @Published var animateDifficultyChange = false
    
    static let shared = GameStateManager()
    
    private init() {}
    
    // Start a new game
    func startGame() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isGameActive = true
            isGameOver = false
            score = 0
            currentTier = 0
            handPositions = []
            
            currentSpeed = DEFAULT_SPEED
            currentSpawnRate = DEFAULT_SPAWN_RATE
        }
        
        startTimer()
    }
    
    // End the game
    func endGame() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isGameActive = false
            isGameOver = true
        }
        stopTimer()
    }
    
    // Go back to menu
    func goToMenu() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isGameActive = false
            isGameOver = false
            handPositions = []
        }
        stopTimer()
    }
    
    // Update screen dimensions
    func updateScreenDimensions(width: CGFloat, height: CGFloat) {
        screenDimensions = CGSize(width: width, height: height)
    }
    
    // Timer management
    private func startTimer() {
        stopTimer()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: currentSpawnRate, repeats: true) { [weak self] _ in
            self?.spawnHand()
            self?.checkForMissedHands()
        }
    }
    
    private func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    // Game logic methods
    private func spawnHand() {
        print("GameStateManager: Spawning hands")
        
        let currentDifficulty = DifficultyTiers[currentTier]

        if (currentDifficulty.maxHandsPerSpawn > 1 && Double.random(in: 0...1) < currentDifficulty.multiHandChance) {
            let numHands = Int.random(in: 2...currentDifficulty.maxHandsPerSpawn)
            print("Spawning \(numHands) hands at once")
            
            for _ in 0..<numHands {
                spawnSingleHand()
            }
        } else {
            spawnSingleHand()
        }
    }
    
    // Spawn a single hand at a random position
    private func spawnSingleHand() {
        print("GameStateManager: Screen dimensions: \(screenDimensions.width) x \(screenDimensions.height)")
        
        // Create a safe margin around the edges
        let margin: CGFloat = handSize
        
        // Generate random coordinates within the safe area
        let randomX = CGFloat.random(in: margin...(screenDimensions.width - margin))
        let randomY = CGFloat.random(in: margin...(screenDimensions.height - margin))
        
        print("GameStateManager: Spawning hand at: \(randomX), \(randomY)")
        
        let handPosition = HandPosition(
            id: UUID(),
            x: randomX,
            y: randomY,
            color: getRandomHandColor(),
            createdAt: Date(),
            timeToLive: currentSpeed
        )
        
        DispatchQueue.main.async {
            withAnimation(.easeIn(duration: 0.3)) {
                self.handPositions.append(handPosition)
            }
        }
    }
    
    // Get a random color for the hand that's different from the last one
    private func getRandomHandColor() -> Color {
        let handColors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .yellow]
        
        // Keep track of last used color index to avoid repeating
        var colorIndex = Int.random(in: 0..<handColors.count)
        
        return handColors[colorIndex]
    }
    
    // Check for hands that have been on screen too long and remove them
    private func checkForMissedHands() {
        let now = Date()
        
        for hand in handPositions {
            let timeOnScreen = now.timeIntervalSince(hand.createdAt)
            // Missed a hand - game over
            if timeOnScreen > hand.timeToLive {
                endGame()
                return
            }
        }
    }
    
    func tapHand(_ hand: HandPosition) {
        if let index = handPositions.firstIndex(where: { $0.id == hand.id }) {
            DispatchQueue.main.async {
                self.handPositions.remove(at: index)
                
                self.score += 1
                
                self.updateDifficulty()
            }
        }
    }
    
    // Method to handle difficulty progression
    private func updateDifficulty() {
        for (index, tier) in DifficultyTiers.enumerated().reversed() {
            if score >= tier.scoreThreshold && index > currentTier {
                // Player has reached a new tier
                currentTier = index
                currentSpeed = tier.handLifetime
                currentSpawnRate = tier.spawnRate
                
                // Start timer with new spawn rate
                startTimer()
                
                // Trigger animation of difficulty change
                triggerDifficultyAnimation()
                break
            }
        }
    }
    
    // Method to trigger the difficulty animation
    private func triggerDifficultyAnimation() {
        // Set animation flag
        animateDifficultyChange = true
        
        // Reset flag after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.animateDifficultyChange = false
        }
    }
} 
