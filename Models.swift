import Foundation
import Combine

// MARK: - Core Models

struct Song: Identifiable, Equatable, Codable {
    let id: UUID
    let title: String
    let artist: String
    let album: String?
    let duration: TimeInterval
    let source: MusicSourceType
    let artworkURL: URL?
    let streamURL: URL?
    let localPath: String?
    
    init(id: UUID = UUID(), 
         title: String, 
         artist: String, 
         album: String? = nil,
         duration: TimeInterval, 
         source: MusicSourceType,
         artworkURL: URL? = nil,
         streamURL: URL? = nil,
         localPath: String? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.source = source
        self.artworkURL = artworkURL
        self.streamURL = streamURL
        self.localPath = localPath
    }
}

enum MusicSourceType: String, CaseIterable, Codable {
    case local = "Local"
    case spotify = "Spotify"
    case audioDB = "AudioDB"
    case discogs = "Discogs"
}

enum PlaybackState: String, CaseIterable {
    case stopped = "Stopped"
    case playing = "Playing"
    case paused = "Paused"
    case loading = "Loading"
    case error = "Error"
}

enum PlayerError: Error, LocalizedError {
    case noSourceSet
    case noSongsAvailable
    case invalidSong
    case networkError
    case audioSessionError
    
    var errorDescription: String? {
        switch self {
        case .noSourceSet:
            return "No music source is set"
        case .noSongsAvailable:
            return "No songs available to play"
        case .invalidSong:
            return "Invalid song selected"
        case .networkError:
            return "Network error occurred"
        case .audioSessionError:
            return "Audio session error"
        }
    }
}

// MARK: - Playback Progress
struct PlaybackProgress {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let progress: Double // 0.0 to 1.0
    
    init(currentTime: TimeInterval, duration: TimeInterval) {
        self.currentTime = currentTime
        self.duration = duration
        self.progress = duration > 0 ? currentTime / duration : 0.0
    }
}

// MARK: - Queue Management
struct QueueItem: Identifiable {
    let id: UUID
    let song: Song
    let addedAt: Date
    
    init(song: Song) {
        self.id = UUID()
        self.song = song
        self.addedAt = Date()
    }
}

// MARK: - Audio Session Configuration
struct AudioSessionConfig {
    let category: String
    let mode: String
    let options: UInt
    
    static let music = AudioSessionConfig(
        category: "playback",
        mode: "default",
        options: 0
    )
} 