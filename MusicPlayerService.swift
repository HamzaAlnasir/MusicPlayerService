import Foundation
import Combine
import AVFoundation

// MARK: - Music Player Service (Singleton Pattern)
class MusicPlayerService: ObservableObject {
    // Singleton instance
    static let shared = MusicPlayerService()
    
    // MARK: - Published Properties (Observable State)
    @Published private(set) var currentSong: Song?
    @Published private(set) var playbackState: PlaybackState = .stopped
    @Published private(set) var playbackProgress: PlaybackProgress = PlaybackProgress(currentTime: 0, duration: 0)
    @Published private(set) var queue: [QueueItem] = []
    @Published private(set) var currentSource: MusicSource?
    @Published private(set) var availableSongs: [Song] = []
    @Published private(set) var errorMessage: String?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var progressTimer: Timer?
    private var currentIndex: Int = 0
    private var audioSession: AVAudioSession?
    
    // MARK: - Initialization
    private init() {
        setupAudioSession()
        setupProgressTimer()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession?.setCategory(.playback, mode: .default)
            try audioSession?.setActive(true)
        } catch {
            print("❌ Failed to setup audio session: \(error)")
            errorMessage = "Audio session setup failed"
        }
    }
    
    // MARK: - Progress Timer
    private func setupProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func updateProgress() {
        guard playbackState == .playing,
              let currentSong = currentSong else { return }
        
        // Simulate progress update
        let newCurrentTime = min(playbackProgress.currentTime + 1, currentSong.duration)
        playbackProgress = PlaybackProgress(currentTime: newCurrentTime, duration: currentSong.duration)
        
        // Auto-advance to next song when current song ends
        if newCurrentTime >= currentSong.duration {
            skip()
        }
    }
    
    // MARK: - Source Management
    func setSource(_ source: MusicSource) {
        currentSource = source
        loadSongs()
    }
    
    private func loadSongs() {
        guard let source = currentSource else {
            errorMessage = "No music source set"
            return
        }
        
        playbackState = .loading
        
        source.loadSongs()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] songs in
                    self?.availableSongs = songs
                    self?.queue = songs.map { QueueItem(song: $0) }
                    self?.currentIndex = 0
                    self?.currentSong = songs.first
                    self?.playbackState = .stopped
                    self?.playbackProgress = PlaybackProgress(currentTime: 0, duration: songs.first?.duration ?? 0)
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Playback Controls
    func play() {
        guard let currentSong = currentSong,
              let source = currentSource else {
            errorMessage = "No song to play"
            return
        }
        
        playbackState = .loading
        
        source.play(song: currentSong)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.playbackState = .playing
                    case .failure(let error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func pause() {
        guard let source = currentSource else { return }
        
        source.pause()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.playbackState = .paused
                    case .failure(let error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func stop() {
        guard let source = currentSource else { return }
        
        source.stop()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.playbackState = .stopped
                        self?.playbackProgress = PlaybackProgress(currentTime: 0, duration: self?.currentSong?.duration ?? 0)
                    case .failure(let error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func skip() {
        guard currentIndex + 1 < queue.count else {
            // End of queue - loop back to beginning
            currentIndex = 0
            currentSong = queue.first?.song
            play()
            return
        }
        
        currentIndex += 1
        currentSong = queue[currentIndex].song
        playbackProgress = PlaybackProgress(currentTime: 0, duration: currentSong?.duration ?? 0)
        play()
    }
    
    func previous() {
        guard currentIndex > 0 else {
            // Beginning of queue - go to end
            currentIndex = queue.count - 1
            currentSong = queue.last?.song
            play()
            return
        }
        
        currentIndex -= 1
        currentSong = queue[currentIndex].song
        playbackProgress = PlaybackProgress(currentTime: 0, duration: currentSong?.duration ?? 0)
        play()
    }
    
    func seek(to time: TimeInterval) {
        guard let source = currentSource,
              let currentSong = currentSong,
              time >= 0 && time <= currentSong.duration else { return }
        
        source.seek(to: time)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.playbackProgress = PlaybackProgress(currentTime: time, duration: currentSong.duration)
                    case .failure(let error):
                        self?.handleError(error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Queue Management
    func addToQueue(_ song: Song) {
        let queueItem = QueueItem(song: song)
        queue.append(queueItem)
    }
    
    func removeFromQueue(at index: Int) {
        guard index < queue.count else { return }
        
        // Don't remove if it's the currently playing song
        if index == currentIndex && playbackState == .playing {
            errorMessage = "Cannot remove currently playing song"
            return
        }
        
        queue.remove(at: index)
        
        // Adjust current index if necessary
        if index < currentIndex {
            currentIndex -= 1
        }
    }
    
    func reorderQueue(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex < queue.count,
              destinationIndex < queue.count,
              sourceIndex != destinationIndex else { return }
        
        let item = queue.remove(at: sourceIndex)
        queue.insert(item, at: destinationIndex)
        
        // Adjust current index if necessary
        if sourceIndex == currentIndex {
            currentIndex = destinationIndex
        } else if sourceIndex < currentIndex && destinationIndex >= currentIndex {
            currentIndex -= 1
        } else if sourceIndex > currentIndex && destinationIndex <= currentIndex {
            currentIndex += 1
        }
    }
    
    func clearQueue() {
        stop()
        queue.removeAll()
        currentIndex = 0
        currentSong = nil
        playbackProgress = PlaybackProgress(currentTime: 0, duration: 0)
    }
    
    func playSong(at index: Int) {
        guard index < queue.count else { return }
        
        currentIndex = index
        currentSong = queue[index].song
        playbackProgress = PlaybackProgress(currentTime: 0, duration: currentSong?.duration ?? 0)
        play()
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        playbackState = .error
        errorMessage = error.localizedDescription
        print("❌ Player error: \(error)")
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Utility Methods
    func getCurrentQueueIndex() -> Int {
        return currentIndex
    }
    
    func isCurrentSong(_ song: Song) -> Bool {
        return currentSong?.id == song.id
    }
    
    func getFormattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Cleanup
    deinit {
        progressTimer?.invalidate()
        cancellables.removeAll()
    }
} 