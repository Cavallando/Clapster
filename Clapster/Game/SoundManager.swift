import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [URL: AVAudioPlayer] = [:]
    private var soundEnabled = true
    
    private init() {
        // Setup audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playSound(named soundName: String, fileExtension: String = "mp3") {
        guard soundEnabled else { return }
        
        // Check if we have a URL for this sound
        guard let url = Bundle.main.url(forResource: soundName, withExtension: fileExtension) else {
            print("Sound file not found: \(soundName).\(fileExtension)")
            return
        }
        
        // Try to reuse existing player
        if let player = audioPlayers[url] {
            player.currentTime = 0 // Reset to beginning
            player.play()
            return
        }
        
        // Create a new player
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayers[url] = player
            player.play()
        } catch {
            print("Failed to play sound \(soundName): \(error)")
        }
    }
    
    // Play a system sound as a fallback if custom sounds aren't available
    func playSystemSound() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // This is a tap sound
    }
    
    func toggleSound(enabled: Bool) {
        soundEnabled = enabled
    }
} 