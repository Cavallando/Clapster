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
    
    // Add hand spawn queue
    private var handSpawnQueue: [HandPosition] = []
    
    // Add separate timers for queue filling and spawning
    private var queueTimer: Timer?
    private var spawnTimer: Timer?
    
    // Control variables for spawn system
    private var currentQueueRate: Double = DEFAULT_QUEUE_RATE // How often we add to queue
    private var currentSpawnRate: Double = DEFAULT_SPAWN_RATE // How often we take from queue
    private var currentHandLifetime: Double = DEFAULT_HAND_LIFETIME // How long hands stay on screen
    
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
            handSpawnQueue = []
            
            currentHandLifetime = DEFAULT_HAND_LIFETIME
            currentQueueRate = DEFAULT_QUEUE_RATE
            currentSpawnRate = DEFAULT_SPAWN_RATE
        }
        
        startTimers()
    }
    
    // End the game
    func endGame() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isGameActive = false
            isGameOver = true
        }
        stopTimers()
    }
    
    // Go back to menu
    func goToMenu() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isGameActive = false
            isGameOver = false
            handPositions = []
        }
        stopTimers()
    }
    
    // Update screen dimensions
    func updateScreenDimensions(width: CGFloat, height: CGFloat) {
        screenDimensions = CGSize(width: width, height: height)
    }
    
    // Timer management
    private func startTimers() {
        stopTimers()
        
        // Timer for adding hands to the queue
        queueTimer = Timer.scheduledTimer(withTimeInterval: currentQueueRate, repeats: true) { [weak self] _ in
            self?.addHandToQueue()
        }
        
        // Timer for taking hands from queue and placing on screen
        spawnTimer = Timer.scheduledTimer(withTimeInterval: currentSpawnRate, repeats: true) { [weak self] _ in
            self?.spawnHandFromQueue()
            self?.checkForMissedHands()
        }
    }
    
    private func stopTimers() {
        queueTimer?.invalidate()
        queueTimer = nil
        
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
    
    // Queue management
    private func addHandToQueue() {
        // Create a hand position
        let handPosition = createHandPosition()
        
        // Add to queue
        handSpawnQueue.append(handPosition)
        
        print("Added hand to queue. Queue size: \(handSpawnQueue.count)")
    }
    
    private func spawnHandFromQueue() {
        // Only spawn if we have hands in the queue
        guard !handSpawnQueue.isEmpty else { 
            print("Queue is empty, nothing to spawn")
            return 
        }
        
        // Take the first hand from the queue
        let handPosition = handSpawnQueue.removeFirst()
        
        // Update the creation timestamp to now
        let updatedHand = HandPosition(
            id: handPosition.id,
            x: handPosition.x,
            y: handPosition.y,
            color: handPosition.color,
            createdAt: Date(),  // Update timestamp to now
            timeToLive: currentHandLifetime
        )
        
        // Add to active hands
        DispatchQueue.main.async {
            withAnimation(.easeIn(duration: 0.3)) {
                self.handPositions.append(updatedHand)
            }
        }
        
        print("Spawned hand from queue. Remaining in queue: \(handSpawnQueue.count)")
    }
    
    // Create a hand position without adding it to the screen
    private func createHandPosition() -> HandPosition {
        // Create a safe margin around the edges
        let margin: CGFloat = handSize
        
        // Generate random coordinates within the safe area
        let randomX = CGFloat.random(in: margin...(screenDimensions.width - margin))
        let randomY = CGFloat.random(in: margin...(screenDimensions.height - margin))
        
        return HandPosition(
            id: UUID(),
            x: randomX,
            y: randomY,
            color: getRandomHandColor(),
            createdAt: Date(),  // This will be updated when actually spawned
            timeToLive: currentHandLifetime
        )
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
                currentHandLifetime = tier.handLifetime
                currentQueueRate = tier.queueRate
                currentSpawnRate = tier.spawnRate
                
                // Update timers with new rates
                startTimers()
                
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
