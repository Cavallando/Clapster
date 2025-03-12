import SwiftUI

struct HandPosition: Identifiable {
    let id: UUID
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let createdAt: Date
    let timeToLive: Double
}

struct DifficultyTier {
    let name: String             // Name of this difficulty tier
    let handLifetime: Double     // How long hands stay visible (seconds)
    let spawnRate: Double        // Time between hand spawns (seconds)
    let multiHandChance: Double  // Probability of spawning multiple hands (0-1)
    let maxHandsPerSpawn: Int    // Maximum hands that can spawn at once
    let scoreThreshold: Int      // Score needed to reach this tier
    let color: Color             // Color associated with this tier
}


let DifficultyTiers: [DifficultyTier] = [
    DifficultyTier(name: "Beginner", handLifetime: 2.0, spawnRate: 2.0, multiHandChance: 0.0, maxHandsPerSpawn: 1, scoreThreshold: 0, color: .primary),
    DifficultyTier(name: "Easy", handLifetime: 1.8, spawnRate: 1.8, multiHandChance: 0.0, maxHandsPerSpawn: 1, scoreThreshold: 5, color: .green),
    DifficultyTier(name: "Medium", handLifetime: 1.6, spawnRate: 1.6, multiHandChance: 0.1, maxHandsPerSpawn: 1, scoreThreshold: 15, color: .blue),
    DifficultyTier(name: "Challenging", handLifetime: 1.4, spawnRate: 1.5, multiHandChance: 0.2, maxHandsPerSpawn: 2, scoreThreshold: 25, color: .darkGreen),
    DifficultyTier(name: "Hard", handLifetime: 1.2, spawnRate: 1.3, multiHandChance: 0.3, maxHandsPerSpawn: 2, scoreThreshold: 40, color: .orange),
    DifficultyTier(name: "Very Hard", handLifetime: 1.0, spawnRate: 1.1, multiHandChance: 0.4, maxHandsPerSpawn: 2, scoreThreshold: 60, color: .darkOrange),
    DifficultyTier(name: "Expert", handLifetime: 0.9, spawnRate: 1.0, multiHandChance: 0.5, maxHandsPerSpawn: 3, scoreThreshold: 85, color: .red),
    DifficultyTier(name: "Master", handLifetime: 0.8, spawnRate: 0.9, multiHandChance: 0.6, maxHandsPerSpawn: 3, scoreThreshold: 110, color: .purple),
    DifficultyTier(name: "Legendary", handLifetime: 0.7, spawnRate: 0.8, multiHandChance: 0.7, maxHandsPerSpawn: 3, scoreThreshold: 140, color: .gold)
]


// Custom color names
extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)

    static let darkOrange = Color(red: 1.0, green: 0.6, blue: 0.0)

    static let darkGreen = Color(red: 0.0, green: 0.5, blue: 0.0)
}
