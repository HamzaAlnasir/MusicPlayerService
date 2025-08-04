import Foundation
import Combine

// MARK: - Music Source Protocol (Strategy Pattern)
protocol MusicSource {
    var sourceType: MusicSourceType { get }
    var displayName: String { get }
    
    func loadSongs() -> AnyPublisher<[Song], Error>
    func play(song: Song) -> AnyPublisher<Void, Error>
    func pause() -> AnyPublisher<Void, Error>
    func stop() -> AnyPublisher<Void, Error>
    func seek(to time: TimeInterval) -> AnyPublisher<Void, Error>
    func getCurrentTime() -> AnyPublisher<TimeInterval, Error>
    func getDuration() -> AnyPublisher<TimeInterval, Error>
}

// MARK: - Local Music Source
class LocalMusicSource: MusicSource {
    let sourceType: MusicSourceType = .local
    let displayName: String = "Local Files"
    
    private let fileManager = FileManager.default
    private let supportedExtensions = ["mp3", "m4a", "wav", "aac"]
    
    func loadSongs() -> AnyPublisher<[Song], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlayerError.networkError))
                return
            }
            
            // Simulate loading local files
            let songs = [
                Song(title: "Local Song 1", artist: "Artist A", album: "Local Album 1", duration: 180, source: .local, localPath: "/path/to/song1.mp3"),
                Song(title: "Local Song 2", artist: "Artist B", album: "Local Album 2", duration: 200, source: .local, localPath: "/path/to/song2.mp3"),
                Song(title: "Local Song 3", artist: "Artist C", album: "Local Album 3", duration: 165, source: .local, localPath: "/path/to/song3.mp3")
            ]
            
            promise(.success(songs))
        }
        .eraseToAnyPublisher()
    }
    
    func play(song: Song) -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("🎵 Playing local song: \(song.title) by \(song.artist)")
            // Simulate audio playback
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func pause() -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("⏸️ Pausing local song")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func stop() -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("⏹️ Stopping local song")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func seek(to time: TimeInterval) -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("⏩ Seeking to \(time) seconds")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func getCurrentTime() -> AnyPublisher<TimeInterval, Error> {
        return Just(0.0).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getDuration() -> AnyPublisher<TimeInterval, Error> {
        return Just(180.0).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

// MARK: - Spotify Music Source (Mock)
class SpotifyMusicSource: MusicSource {
    let sourceType: MusicSourceType = .spotify
    let displayName: String = "Spotify"
    
    private let apiKey = "mock_spotify_api_key"
    
    func loadSongs() -> AnyPublisher<[Song], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlayerError.networkError))
                return
            }
            
            // Simulate Spotify API call
            let songs = [
                Song(title: "Spotify Song 1", artist: "Artist X", album: "Spotify Album 1", duration: 240, source: .spotify, streamURL: URL(string: "https://spotify.com/stream/1")),
                Song(title: "Spotify Song 2", artist: "Artist Y", album: "Spotify Album 2", duration: 260, source: .spotify, streamURL: URL(string: "https://spotify.com/stream/2")),
                Song(title: "Spotify Song 3", artist: "Artist Z", album: "Spotify Album 3", duration: 195, source: .spotify, streamURL: URL(string: "https://spotify.com/stream/3"))
            ]
            
            print("📡 Loading songs from Spotify...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                promise(.success(songs))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func play(song: Song) -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("🎵 Streaming Spotify song: \(song.title) by \(song.artist)")
            // Simulate streaming
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func pause() -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("⏸️ Pausing Spotify stream")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func stop() -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("⏹️ Stopping Spotify stream")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func seek(to time: TimeInterval) -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("⏩ Seeking Spotify stream to \(time) seconds")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func getCurrentTime() -> AnyPublisher<TimeInterval, Error> {
        return Just(0.0).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getDuration() -> AnyPublisher<TimeInterval, Error> {
        return Just(240.0).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

// MARK: - AudioDB Response Models
struct AudioDBResponse: Codable {
    let track: [AudioDBTrack]?
}

struct AudioDBSearchResponse: Codable {
    let track: [AudioDBTrack]?
}

struct AudioDBTrack: Codable {
    let strTrack: String?
    let strArtist: String?
    let strAlbum: String?
    let intDuration: Int?
    let strTrackThumb: String?
    let strMusicVid: String?
}

// MARK: - AudioDB Music Source
class AudioDBMusicSource: MusicSource {
    let sourceType: MusicSourceType = .audioDB
    let displayName: String = "AudioDB"
    
    private let baseURL = "https://www.theaudiodb.com/api/v1/json"
    private let apiKey = "2" // Default API key for AudioDB
    private var cancellables = Set<AnyCancellable>()
    
    func loadSongs() -> AnyPublisher<[Song], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlayerError.networkError))
                return
            }
            
            // Use the provided API endpoint
            let urlString = "\(self.baseURL)/\(self.apiKey)/track.php?m=2115888"
            guard let url = URL(string: urlString) else {
                promise(.failure(PlayerError.networkError))
                return
            }
            
            print("📡 Loading songs from AudioDB API: \(urlString)")
            
            URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .decode(type: AudioDBResponse.self, decoder: JSONDecoder())
                .map { response in
                    // Convert AudioDB tracks to Song objects
                    return response.track?.map { track in
                        Song(
                            title: track.strTrack ?? "Unknown Track",
                            artist: track.strArtist ?? "Unknown Artist",
                            album: track.strAlbum,
                            duration: TimeInterval(track.intDuration ?? 0),
                            source: .audioDB,
                            artworkURL: track.strTrackThumb != nil ? URL(string: track.strTrackThumb!) : nil,
                            streamURL: track.strMusicVid != nil ? URL(string: track.strMusicVid!) : nil,
                            localPath: nil
                        )
                    } ?? []
                }
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            print("❌ AudioDB API Error: \(error)")
                            // Fallback to mock data if API fails
                            let fallbackSongs = [
                                Song(title: "AudioDB Song 1", artist: "Artist A", album: "AudioDB Album 1", duration: 210, source: .audioDB, artworkURL: URL(string: "https://audiodb.com/artwork/1.jpg")),
                                Song(title: "AudioDB Song 2", artist: "Artist B", album: "AudioDB Album 2", duration: 225, source: .audioDB, artworkURL: URL(string: "https://audiodb.com/artwork/2.jpg")),
                                Song(title: "AudioDB Song 3", artist: "Artist C", album: "AudioDB Album 3", duration: 198, source: .audioDB, artworkURL: URL(string: "https://audiodb.com/artwork/3.jpg"))
                            ]
                            promise(.success(fallbackSongs))
                        }
                    },
                    receiveValue: { songs in
                        print("✅ Loaded \(songs.count) songs from AudioDB API")
                        promise(.success(songs))
                    }
                )
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func play(song: Song) -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("🎵 Playing AudioDB song: \(song.title) by \(song.artist)")
            
            // Use stream URL if available, otherwise simulate playback
            if let streamURL = song.streamURL {
                print("🔗 Streaming from URL: \(streamURL)")
                // In a real implementation, you would use AVPlayer to stream from this URL
            } else {
                print("📱 Simulating AudioDB playback (no stream URL available)")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func pause() -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("⏸️ Pausing AudioDB song")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func stop() -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("⏹️ Stopping AudioDB song")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func seek(to time: TimeInterval) -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("⏩ Seeking AudioDB song to \(time) seconds")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func getCurrentTime() -> AnyPublisher<TimeInterval, Error> {
        return Just(0.0).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getDuration() -> AnyPublisher<TimeInterval, Error> {
        return Just(210.0).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    // MARK: - Additional AudioDB Methods
    
    func searchTracks(query: String) -> AnyPublisher<[Song], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlayerError.networkError))
                return
            }
            
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            let urlString = "\(self.baseURL)/\(self.apiKey)/search.php?s=\(encodedQuery)"
            guard let url = URL(string: urlString) else {
                promise(.failure(PlayerError.networkError))
                return
            }
            
            print("🔍 Searching AudioDB for: \(query)")
            
            URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .decode(type: AudioDBSearchResponse.self, decoder: JSONDecoder())
                .map { response in
                    return response.track?.map { track in
                        Song(
                            title: track.strTrack ?? "Unknown Track",
                            artist: track.strArtist ?? "Unknown Artist",
                            album: track.strAlbum,
                            duration: TimeInterval(track.intDuration ?? 0),
                            source: .audioDB,
                            artworkURL: track.strTrackThumb != nil ? URL(string: track.strTrackThumb!) : nil,
                            streamURL: track.strMusicVid != nil ? URL(string: track.strMusicVid!) : nil,
                            localPath: nil
                        )
                    } ?? []
                }
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            print("❌ AudioDB Search Error: \(error)")
                            promise(.success([]))
                        }
                    },
                    receiveValue: { songs in
                        print("✅ Found \(songs.count) tracks for '\(query)'")
                        promise(.success(songs))
                    }
                )
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Discogs Music Source
class DiscogsMusicSource: MusicSource {
    let sourceType: MusicSourceType = .discogs
    let displayName: String = "Discogs"
    
    private let apiKey = "mock_discogs_api_key"
    
    func loadSongs() -> AnyPublisher<[Song], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlayerError.networkError))
                return
            }
            
            // Simulate Discogs API call
            let songs = [
                Song(title: "Discogs Song 1", artist: "Artist X", album: "Discogs Album 1", duration: 185, source: .discogs, artworkURL: URL(string: "https://discogs.com/artwork/1.jpg")),
                Song(title: "Discogs Song 2", artist: "Artist Y", album: "Discogs Album 2", duration: 220, source: .discogs, artworkURL: URL(string: "https://discogs.com/artwork/2.jpg")),
                Song(title: "Discogs Song 3", artist: "Artist Z", album: "Discogs Album 3", duration: 175, source: .discogs, artworkURL: URL(string: "https://discogs.com/artwork/3.jpg"))
            ]
            
            print("📡 Loading songs from Discogs...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                promise(.success(songs))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func play(song: Song) -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("🎵 Playing Discogs song: \(song.title) by \(song.artist)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func pause() -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("⏸️ Pausing Discogs song")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func stop() -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("⏹️ Stopping Discogs song")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func seek(to time: TimeInterval) -> AnyPublisher<Void, Error> {
        return Future { promise in
            print("⏩ Seeking Discogs song to \(time) seconds")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func getCurrentTime() -> AnyPublisher<TimeInterval, Error> {
        return Just(0.0).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getDuration() -> AnyPublisher<TimeInterval, Error> {
        return Just(185.0).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
} 