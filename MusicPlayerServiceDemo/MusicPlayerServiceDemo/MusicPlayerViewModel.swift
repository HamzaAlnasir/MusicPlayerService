import Foundation
import Combine
import SwiftUI

// MARK: - Music Player ViewModel (MVVM Pattern)
class MusicPlayerViewModel: ObservableObject {
    // MARK: - Published Properties (UI State)
    @Published var currentSongTitle: String = "No song selected"
    @Published var currentArtist: String = ""
    @Published var currentAlbum: String = ""
    @Published var isPlaying: Bool = false
    @Published var isPaused: Bool = false
    @Published var isLoading: Bool = false
    @Published var currentTime: String = "0:00"
    @Published var totalTime: String = "0:00"
    @Published var progress: Double = 0.0
    @Published var queueItems: [QueueItem] = []
    @Published var availableSongs: [Song] = []
    @Published var currentSourceName: String = "No source"
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // MARK: - Private Properties
    private let playerService = MusicPlayerService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Combine Bindings
    private func setupBindings() {
        // Current song binding
        playerService.$currentSong
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] song in
                self?.currentSongTitle = song.title
                self?.currentArtist = song.artist
                self?.currentAlbum = song.album ?? "Unknown Album"
            }
            .store(in: &cancellables)
        
        // Playback state binding
        playerService.$playbackState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updatePlaybackState(state)
            }
            .store(in: &cancellables)
        
        // Progress binding
        playerService.$playbackProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.updateProgress(progress)
            }
            .store(in: &cancellables)
        
        // Queue binding
        playerService.$queue
            .receive(on: DispatchQueue.main)
            .assign(to: &$queueItems)
        
        // Available songs binding
        playerService.$availableSongs
            .receive(on: DispatchQueue.main)
            .assign(to: &$availableSongs)
        
        // Current source binding
        playerService.$currentSource
            .compactMap { $0?.displayName }
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentSourceName)
        
        // Error binding
        playerService.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.errorMessage = errorMessage
                self?.showError = errorMessage != nil
            }
            .store(in: &cancellables)
    }
    
    // MARK: - State Updates
    private func updatePlaybackState(_ state: PlaybackState) {
        switch state {
        case .playing:
            isPlaying = true
            isPaused = false
            isLoading = false
        case .paused:
            isPlaying = false
            isPaused = true
            isLoading = false
        case .stopped:
            isPlaying = false
            isPaused = false
            isLoading = false
        case .loading:
            isLoading = true
        case .error:
            isPlaying = false
            isPaused = false
            isLoading = false
        }
    }
    
    private func updateProgress(_ progress: PlaybackProgress) {
        currentTime = playerService.getFormattedTime(progress.currentTime)
        totalTime = playerService.getFormattedTime(progress.duration)
        self.progress = progress.progress
    }
    
    // MARK: - Public Methods (User Actions)
    func playPauseToggle() {
        if isPlaying {
            playerService.pause()
        } else {
            playerService.play()
        }
    }
    
    func skip() {
        playerService.skip()
    }
    
    func previous() {
        playerService.previous()
    }
    
    func stop() {
        playerService.stop()
    }
    
    func seek(to progress: Double) {
        guard let currentSong = playerService.currentSong else { return }
        let time = currentSong.duration * progress
        playerService.seek(to: time)
    }
    
    func setSource(_ source: MusicSource) {
        playerService.setSource(source)
    }
    
    func addToQueue(_ song: Song) {
        playerService.addToQueue(song)
    }
    
    func removeFromQueue(at index: Int) {
        playerService.removeFromQueue(at: index)
    }
    
    func playSong(at index: Int) {
        playerService.playSong(at: index)
    }
    
    func clearQueue() {
        playerService.clearQueue()
    }
    
    func clearError() {
        playerService.clearError()
    }
    
    // MARK: - Utility Methods
    func isCurrentSong(_ song: Song) -> Bool {
        return playerService.isCurrentSong(song)
    }
    
    func getCurrentQueueIndex() -> Int {
        return playerService.getCurrentQueueIndex()
    }
    
    func getSourceIcon(for sourceType: MusicSourceType) -> String {
        switch sourceType {
        case .local:
            return "music.note"
        case .spotify:
            return "music.note.list"
        case .audioDB:
            return "music.mic"
        case .discogs:
            return "music.note.house"
        }
    }
    
    func getSourceColor(for sourceType: MusicSourceType) -> Color {
        switch sourceType {
        case .local:
            return .blue
        case .spotify:
            return .green
        case .audioDB:
            return .orange
        case .discogs:
            return .purple
        }
    }
    
    func getPlaybackStateIcon() -> String {
        switch playerService.playbackState {
        case .playing:
            return "pause.circle.fill"
        case .paused, .stopped:
            return "play.circle.fill"
        case .loading:
            return "clock.circle.fill"
        case .error:
            return "exclamationmark.circle.fill"
        }
    }
    
    func getPlaybackStateColor() -> Color {
        switch playerService.playbackState {
        case .playing:
            return .green
        case .paused:
            return .orange
        case .stopped:
            return .gray
        case .loading:
            return .blue
        case .error:
            return .red
        }
    }
} 