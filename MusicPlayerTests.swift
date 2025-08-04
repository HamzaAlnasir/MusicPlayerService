import Foundation
import Combine
import XCTest

// MARK: - Music Player Tests
class MusicPlayerTests {
    
    // MARK: - Test Properties
    private var cancellables = Set<AnyCancellable>()
    private let playerService = MusicPlayerService.shared
    
    // MARK: - Test Methods
    
    func testSingletonPattern() {
        let instance1 = MusicPlayerService.shared
        let instance2 = MusicPlayerService.shared
        
        // Verify singleton pattern - same instance
        assert(instance1 === instance2, "Singleton pattern failed: instances are not the same")
        print("✅ Singleton pattern test passed")
    }
    
    func testStrategyPattern() {
        let localSource = LocalMusicSource()
        let spotifySource = SpotifyMusicSource()
        let audioDBSource = AudioDBMusicSource()
        let discogsSource = DiscogsMusicSource()
        
        // Verify all sources implement the same interface
        assert(localSource.sourceType == .local)
        assert(spotifySource.sourceType == .spotify)
        assert(audioDBSource.sourceType == .audioDB)
        assert(discogsSource.sourceType == .discogs)
        
        print("✅ Strategy pattern test passed")
    }
    
    func testLocalMusicSource() {
        let source = LocalMusicSource()
        let expectation = XCTestExpectation(description: "Load local songs")
        
        source.loadSongs()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        print("❌ Local source test failed: \(error)")
                    }
                },
                receiveValue: { songs in
                    assert(!songs.isEmpty, "Local source should return songs")
                    print("✅ Local music source test passed - loaded \(songs.count) songs")
                }
            )
            .store(in: &cancellables)
        
        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
    }
    
    func testSpotifyMusicSource() {
        let source = SpotifyMusicSource()
        let expectation = XCTestExpectation(description: "Load Spotify songs")
        
        source.loadSongs()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        print("❌ Spotify source test failed: \(error)")
                    }
                },
                receiveValue: { songs in
                    assert(!songs.isEmpty, "Spotify source should return songs")
                    print("✅ Spotify music source test passed - loaded \(songs.count) songs")
                }
            )
            .store(in: &cancellables)
        
        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
    }
    
    func testAudioDBMusicSource() {
        let source = AudioDBMusicSource()
        let expectation = XCTestExpectation(description: "Load AudioDB songs")
        
        source.loadSongs()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        print("❌ AudioDB source test failed: \(error)")
                    }
                },
                receiveValue: { songs in
                    assert(!songs.isEmpty, "AudioDB source should return songs")
                    print("✅ AudioDB music source test passed - loaded \(songs.count) songs")
                }
            )
            .store(in: &cancellables)
        
        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
    }
    
    func testDiscogsMusicSource() {
        let source = DiscogsMusicSource()
        let expectation = XCTestExpectation(description: "Load Discogs songs")
        
        source.loadSongs()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        print("❌ Discogs source test failed: \(error)")
                    }
                },
                receiveValue: { songs in
                    assert(!songs.isEmpty, "Discogs source should return songs")
                    print("✅ Discogs music source test passed - loaded \(songs.count) songs")
                }
            )
            .store(in: &cancellables)
        
        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
    }
    
    func testPlaybackControls() {
        let source = LocalMusicSource()
        playerService.setSource(source)
        
        // Test play
        playerService.play()
        assert(playerService.playbackState == .loading || playerService.playbackState == .playing)
        
        // Test pause
        playerService.pause()
        assert(playerService.playbackState == .paused)
        
        // Test stop
        playerService.stop()
        assert(playerService.playbackState == .stopped)
        
        print("✅ Playback controls test passed")
    }
    
    func testQueueManagement() {
        let source = LocalMusicSource()
        playerService.setSource(source)
        
        // Wait for songs to load
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let initialQueueCount = self.playerService.queue.count
            
            // Test adding song to queue
            if let firstSong = self.playerService.availableSongs.first {
                self.playerService.addToQueue(firstSong)
                assert(self.playerService.queue.count == initialQueueCount + 1)
            }
            
            // Test removing song from queue
            if self.playerService.queue.count > 0 {
                self.playerService.removeFromQueue(at: 0)
                assert(self.playerService.queue.count == initialQueueCount)
            }
            
            print("✅ Queue management test passed")
        }
    }
    
    func testErrorHandling() {
        // Test with no source set
        playerService.clearError()
        playerService.play()
        
        // Should have error message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            assert(self.playerService.errorMessage != nil)
            print("✅ Error handling test passed")
        }
    }
    
    func testProgressTracking() {
        let source = LocalMusicSource()
        playerService.setSource(source)
        
        // Wait for songs to load and start playing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.playerService.play()
            
            // Wait for progress to update
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let progress = self.playerService.playbackProgress
                assert(progress.currentTime >= 0)
                assert(progress.duration > 0)
                print("✅ Progress tracking test passed")
            }
        }
    }
    
    // MARK: - Run All Tests
    func runAllTests() {
        print("🧪 Running Music Player Tests...")
        print("=" * 50)
        
        testSingletonPattern()
        testStrategyPattern()
        testLocalMusicSource()
        testSpotifyMusicSource()
        testAudioDBMusicSource()
        testDiscogsMusicSource()
        testPlaybackControls()
        testQueueManagement()
        testErrorHandling()
        testProgressTracking()
        
        print("=" * 50)
        print("🎉 All tests completed!")
    }
}

// MARK: - Test Runner
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

// MARK: - Demo Usage
class MusicPlayerDemo {
    
    static func runDemo() {
        print("🎵 Music Player Service Demo")
        print("=" * 50)
        
        let playerService = MusicPlayerService.shared
        let viewModel = MusicPlayerViewModel()
        
        // Demo 1: Switch between sources
        print("\n📡 Demo 1: Switching Music Sources")
        demoSourceSwitching(playerService: playerService, viewModel: viewModel)
        
        // Demo 2: Playback controls
        print("\n🎮 Demo 2: Playback Controls")
        demoPlaybackControls(playerService: playerService, viewModel: viewModel)
        
        // Demo 3: Queue management
        print("\n📋 Demo 3: Queue Management")
        demoQueueManagement(playerService: playerService, viewModel: viewModel)
        
        print("\n" + "=" * 50)
        print("🎉 Demo completed!")
    }
    
    private static func demoSourceSwitching(playerService: MusicPlayerService, viewModel: MusicPlayerViewModel) {
        let sources: [MusicSource] = [
            LocalMusicSource(),
            SpotifyMusicSource(),
            AudioDBMusicSource(),
            DiscogsMusicSource()
        ]
        
        for source in sources {
            print("🔄 Switching to \(source.displayName)...")
            playerService.setSource(source)
            
            // Wait for songs to load
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("✅ \(source.displayName): \(playerService.availableSongs.count) songs loaded")
            }
        }
    }
    
    private static func demoPlaybackControls(playerService: MusicPlayerService, viewModel: MusicPlayerViewModel) {
        // Set local source for demo
        playerService.setSource(LocalMusicSource())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("▶️ Playing...")
            playerService.play()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("⏸️ Pausing...")
                playerService.pause()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    print("▶️ Resuming...")
                    playerService.play()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        print("⏭️ Skipping...")
                        playerService.skip()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            print("⏹️ Stopping...")
                            playerService.stop()
                        }
                    }
                }
            }
        }
    }
    
    private static func demoQueueManagement(playerService: MusicPlayerService, viewModel: MusicPlayerViewModel) {
        playerService.setSource(LocalMusicSource())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("📋 Initial queue: \(playerService.queue.count) songs")
            
            // Add a song to queue
            if let song = playerService.availableSongs.first {
                playerService.addToQueue(song)
                print("➕ Added song to queue: \(song.title)")
                print("📋 Queue now has: \(playerService.queue.count) songs")
            }
            
            // Remove a song from queue
            if playerService.queue.count > 0 {
                playerService.removeFromQueue(at: 0)
                print("➖ Removed song from queue")
                print("📋 Queue now has: \(playerService.queue.count) songs")
            }
        }
    }
}

// MARK: - Usage Example
#if DEBUG
// Uncomment to run tests and demo
// let tests = MusicPlayerTests()
// tests.runAllTests()
// MusicPlayerDemo.runDemo()
#endif 