import SwiftUI

struct HandPosition: Identifiable {
    let id: UUID
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let createdAt: Date
    let timeToLive: Double
}

struct DifficultyTier: Identifiable {
    var id = UUID()
    var name: String
    var handLifetime: Double  // How long hands stay on screen
    var spawnRate: Double     // How often we take from queue (lower = faster)
    var queueRate: Double     // How often we add to queue (lower = faster)
    var scoreThreshold: Int
    var color: Color
}

let DEFAULT_HAND_LIFETIME = 2.0
let DEFAULT_SPAWN_RATE = 0.8    // Take from queue every 0.8 seconds
let DEFAULT_QUEUE_RATE = 2.0    // Add to queue every 2 seconds

let DifficultyTiers: [DifficultyTier] = [
    // Tier 0 - Beginner
    DifficultyTier(name: "Beginner", handLifetime: 2.0, spawnRate: 0.8, queueRate: 2.0, scoreThreshold: 0, color: .blue),
    // Tier 1 - Easy
    DifficultyTier(name: "Easy", handLifetime: 1.8, spawnRate: 0.8, queueRate: 1.8, scoreThreshold: 5, color: .green),
    // Tier 2 - Medium
    DifficultyTier(name: "Medium", handLifetime: 1.6, spawnRate: 0.7, queueRate: 1.5, scoreThreshold: 15, color: .darkGreen),
    // Tier 3 - Challenging
    DifficultyTier(name: "Challenging", handLifetime: 1.4, spawnRate: 0.5, queueRate: 1.1, scoreThreshold: 25, color: .blue),
    // Tier 4 - Hard
    DifficultyTier(name: "Hard", handLifetime: 1.2, spawnRate: 0.4, queueRate: 1.0, scoreThreshold: 40, color: .orange),
    // Tier 5 - Very Hard
    DifficultyTier(name: "Very Hard", handLifetime: 1.0, spawnRate: 0.4, queueRate: 0.9, scoreThreshold: 60, color: .darkOrange),
    // Tier 6 - Expert
    DifficultyTier(name: "Expert", handLifetime: 0.9, spawnRate: 0.35, queueRate: 0.7, scoreThreshold: 85, color: .red),
    // Tier 7 - Master
    DifficultyTier(name: "Master", handLifetime: 0.8, spawnRate: 0.3, queueRate: 0.5, scoreThreshold: 110, color: .gold),
    // Tier 8 - Legendary
    DifficultyTier(name: "Legendary", handLifetime: 0.7, spawnRate: 0.25, queueRate: 0.4, scoreThreshold: 140, color: .purple)
]

// Custom color names
extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)

    static let darkOrange = Color(red: 1.0, green: 0.6, blue: 0.0)

    static let darkGreen = Color(red: 0.0, green: 0.5, blue: 0.0)
}
