import Foundation
import Combine

// MARK: - Music Player Service Demo
// This file demonstrates how to use the Music Player Service
// and showcases the implemented design patterns

class MusicPlayerDemo {
    
    // MARK: - Demo Properties
    private let playerService = MusicPlayerService.shared
    private let viewModel = MusicPlayerViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Demo Methods
    
    func runCompleteDemo() {
        print("🎵 Music Player Service - Design Patterns Demo")
        print("=" * 60)
        
        // Demo 1: Singleton Pattern
        demoSingletonPattern()
        
        // Demo 2: Strategy Pattern
        demoStrategyPattern()
        
        // Demo 3: Observer Pattern (Combine)
        demoObserverPattern()
        
        // Demo 4: MVVM Pattern
        demoMVVMPattern()
        
        // Demo 5: Full Music Player Workflow
        demoFullWorkflow()
        
        print("=" * 60)
        print("🎉 Demo completed successfully!")
    }
    
    // MARK: - Singleton Pattern Demo
    private func demoSingletonPattern() {
        print("\n🔧 Demo 1: Singleton Pattern")
        print("-" * 30)
        
        let instance1 = MusicPlayerService.shared
        let instance2 = MusicPlayerService.shared
        
        print("Instance 1: \(instance1)")
        print("Instance 2: \(instance2)")
        print("Are they the same? \(instance1 === instance2 ? "✅ Yes" : "❌ No")")
        print("✅ Singleton pattern ensures only one player instance exists")
    }
    
    // MARK: - Strategy Pattern Demo
    private func demoStrategyPattern() {
        print("\n🎯 Demo 2: Strategy Pattern")
        print("-" * 30)
        
        let sources: [MusicSource] = [
            LocalMusicSource(),
            SpotifyMusicSource(),
            AudioDBMusicSource(),
            DiscogsMusicSource()
        ]
        
        print("Available music sources:")
        for source in sources {
            print("  • \(source.displayName) (\(source.sourceType.rawValue))")
        }
        
        print("\nAll sources implement the same MusicSource protocol:")
        print("  - loadSongs() -> AnyPublisher<[Song], Error>")
        print("  - play(song: Song) -> AnyPublisher<Void, Error>")
        print("  - pause() -> AnyPublisher<Void, Error>")
        print("  - stop() -> AnyPublisher<Void, Error>")
        print("  - seek(to: TimeInterval) -> AnyPublisher<Void, Error>")
        
        print("✅ Strategy pattern allows easy switching between music sources")
    }
    
    // MARK: - Observer Pattern Demo
    private func demoObserverPattern() {
        print("\n👁️ Demo 3: Observer Pattern (Combine)")
        print("-" * 30)
        
        // Subscribe to player state changes
        playerService.$playbackState
            .sink { state in
                print("🔄 Playback state changed to: \(state.rawValue)")
            }
            .store(in: &cancellables)
        
        // Subscribe to current song changes
        playerService.$currentSong
            .compactMap { $0 }
            .sink { song in
                print("🎵 Now playing: \(song.title) by \(song.artist)")
            }
            .store(in: &cancellables)
        
        // Subscribe to progress updates
        playerService.$playbackProgress
            .sink { progress in
                print("📊 Progress: \(Int(progress.currentTime))s / \(Int(progress.duration))s (\(Int(progress.progress * 100))%)")
            }
            .store(in: &cancellables)
        
        print("✅ Observer pattern provides reactive updates using Combine")
    }
    
    // MARK: - MVVM Pattern Demo
    private func demoMVVMPattern() {
        print("\n🏗️ Demo 4: MVVM Pattern")
        print("-" * 30)
        
        print("Model (Data Layer):")
        print("  • Song struct with song metadata")
        print("  • PlaybackState enum for player states")
        print("  • QueueItem struct for queue management")
        
        print("\nView (UI Layer):")
        print("  • PlayerView - Main player interface")
        print("  • QueueView - Queue management")
        print("  • LibraryView - Song library")
        print("  • SettingsView - Player settings")
        
        print("\nViewModel (Business Logic):")
        print("  • MusicPlayerViewModel - Handles UI state")
        print("  • Binds to MusicPlayerService using Combine")
        print("  • Provides user action methods")
        print("  • Manages error presentation")
        
        print("✅ MVVM pattern separates concerns and makes code testable")
    }
    
    // MARK: - Full Workflow Demo
    private func demoFullWorkflow() {
        print("\n🎮 Demo 5: Full Music Player Workflow")
        print("-" * 30)
        
        // Step 1: Set music source
        print("1️⃣ Setting music source to Local...")
        playerService.setSource(LocalMusicSource())
        
        // Step 2: Wait for songs to load
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("2️⃣ Songs loaded: \(self.playerService.availableSongs.count) available")
            
            // Step 3: Start playing
            print("3️⃣ Starting playback...")
            self.playerService.play()
            
            // Step 4: Demonstrate controls
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("4️⃣ Pausing playback...")
                self.playerService.pause()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    print("5️⃣ Resuming playback...")
                    self.playerService.play()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        print("6️⃣ Skipping to next song...")
                        self.playerService.skip()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            print("7️⃣ Stopping playback...")
                            self.playerService.stop()
                            
                            // Step 5: Queue management
                            print("8️⃣ Adding songs to queue...")
                            for song in self.playerService.availableSongs.prefix(3) {
                                self.playerService.addToQueue(song)
                                print("   ➕ Added: \(song.title)")
                            }
                            
                            print("9️⃣ Queue now has \(self.playerService.queue.count) songs")
                            
                            // Step 6: Switch sources
                            print("🔟 Switching to Spotify...")
                            self.playerService.setSource(SpotifyMusicSource())
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                print("✅ Workflow completed successfully!")
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Usage Examples

// Example 1: Basic Usage
func basicUsageExample() {
    let player = MusicPlayerService.shared
    let viewModel = MusicPlayerViewModel()
    
    // Set source and play
    player.setSource(LocalMusicSource())
    player.play()
    
    // Control playback
    player.pause()
    player.skip()
    player.previous()
    player.stop()
}

// Example 2: Queue Management
func queueManagementExample() {
    let player = MusicPlayerService.shared
    
    // Add songs to queue
    let song1 = Song(title: "Song 1", artist: "Artist 1", duration: 180, source: .local)
    let song2 = Song(title: "Song 2", artist: "Artist 2", duration: 200, source: .local)
    
    player.addToQueue(song1)
    player.addToQueue(song2)
    
    // Remove song from queue
    player.removeFromQueue(at: 0)
    
    // Clear queue
    player.clearQueue()
}

// Example 3: Multiple Sources
func multipleSourcesExample() {
    let player = MusicPlayerService.shared
    
    // Switch between sources
    player.setSource(LocalMusicSource())
    // ... use local source
    
    player.setSource(SpotifyMusicSource())
    // ... use Spotify source
    
    player.setSource(AudioDBMusicSource())
    // ... use AudioDB source
    
    player.setSource(DiscogsMusicSource())
    // ... use Discogs source
}

// Example 4: Error Handling
func errorHandlingExample() {
    let player = MusicPlayerService.shared
    
    // Try to play without setting source
    player.play() // This will trigger an error
    
    // Check for errors
    if let error = player.errorMessage {
        print("Error: \(error)")
        player.clearError()
    }
}

// MARK: - Design Pattern Benefits

/*
 🎯 Design Pattern Benefits:

 1. Singleton Pattern:
    ✅ Ensures only one player instance
    ✅ Centralized state management
    ✅ Global access point
    ✅ Prevents resource conflicts

 2. Strategy Pattern:
    ✅ Easy to add new music sources
    ✅ Open/closed principle
    ✅ Runtime source switching
    ✅ Unified interface for all sources

 3. Observer Pattern (Combine):
    ✅ Reactive UI updates
    ✅ Loose coupling between components
    ✅ Automatic state synchronization
    ✅ Declarative data flow

 4. MVVM Pattern:
    ✅ Separation of concerns
    ✅ Testable business logic
    ✅ Reusable components
    ✅ Clear data flow
    ✅ Maintainable codebase
 */

// MARK: - Run Demo
#if DEBUG
// Uncomment to run the demo
// let demo = MusicPlayerDemo()
// demo.runCompleteDemo()
#endif 