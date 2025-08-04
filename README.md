# Music Player Service - Design Patterns Challenge

A comprehensive music player service built in Swift that demonstrates core design patterns with MVVM architecture and Combine for reactive data communication.

## 🎯 Challenge Overview

This project implements a flexible music player system that can play songs from multiple sources (local files, streaming services) with a unified interface, demonstrating understanding of:

- **Design Patterns**: Singleton, Strategy, Observer, MVVM
- **Architecture**: MVVM + Combine
- **Extensibility**: Easy to add new music sources
- **State Management**: Reactive UI updates with Combine

## 🏗️ Architecture

### MVVM + Combine Pattern

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   SwiftUI Views │◄──►│  ViewModel       │◄──►│  MusicPlayer    │
│   (UI Layer)    │    │  (Business Logic)│    │  Service        │
│                 │    │                  │    │  (Data Layer)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              ▲
                              │ Combine Publishers
                              ▼
                       ┌──────────────────┐
                       │  Music Sources   │
                       │  (Strategy)      │
                       └──────────────────┘
```

## 🎨 Design Patterns Implemented

### 1. Singleton Pattern
- **MusicPlayerService**: Ensures only one player instance exists
- Manages audio session and global state
- Provides centralized access point

```swift
class MusicPlayerService: ObservableObject {
    static let shared = MusicPlayerService()
    private init() { /* setup */ }
}
```

### 2. Strategy Pattern
- **MusicSource Protocol**: Unified interface for different music sources
- **Concrete Strategies**: LocalMusicSource, SpotifyMusicSource, AudioDBMusicSource, DiscogsMusicSource
- Easy to add new sources without modifying existing code

```swift
protocol MusicSource {
    func loadSongs() -> AnyPublisher<[Song], Error>
    func play(song: Song) -> AnyPublisher<Void, Error>
    // ... other methods
}
```

### 3. Observer Pattern (Combine)
- **@Published Properties**: Reactive state management
- **Combine Publishers**: Automatic UI updates
- **Data Binding**: ViewModel observes Service changes

```swift
@Published private(set) var currentSong: Song?
@Published private(set) var playbackState: PlaybackState
```

### 4. MVVM Pattern
- **Model**: Song, PlaybackState, QueueItem data structures
- **View**: SwiftUI views (PlayerView, QueueView, LibraryView)
- **ViewModel**: MusicPlayerViewModel with business logic

## 🎵 Features

### Multiple Music Sources
- ✅ **Local Files**: Simulated local music files
- ✅ **Spotify**: Mock streaming service
- ✅ **AudioDB**: Integration with TheAudioDB API
- ✅ **Discogs**: Integration with Discogs API

### Playback Control
- ✅ **Play/Pause**: Toggle playback state
- ✅ **Skip/Previous**: Navigate through queue
- ✅ **Stop**: Stop playback and reset
- ✅ **Seek**: Jump to specific time position

### Queue Management
- ✅ **Add Songs**: Add songs to queue
- ✅ **Remove Songs**: Remove songs from queue
- ✅ **Reorder**: Drag and drop reordering
- ✅ **Clear Queue**: Remove all songs

### State Notifications
- ✅ **Progress Updates**: Real-time playback progress
- ✅ **State Changes**: Playing, paused, stopped, loading, error
- ✅ **Error Handling**: User-friendly error messages
- ✅ **Auto-advance**: Automatic next song when current ends

## 📱 UI Components

### 1. Player View
- Album art placeholder
- Song information display
- Progress bar with time indicators
- Playback control buttons
- Source indicator

### 2. Queue View
- List of queued songs
- Current song highlighting
- Remove song functionality
- Clear queue option

### 3. Library View
- Source selection picker
- Available songs list
- Add to queue functionality
- Song metadata display

### 4. Settings View
- Player information
- Playback controls
- Queue management options

## 🔧 Technical Implementation

### Core Models

```swift
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
}

enum PlaybackState: String, CaseIterable {
    case stopped = "Stopped"
    case playing = "Playing"
    case paused = "Paused"
    case loading = "Loading"
    case error = "Error"
}

struct PlaybackProgress {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let progress: Double
}
```

### Music Sources

Each music source implements the `MusicSource` protocol:

```swift
class LocalMusicSource: MusicSource {
    func loadSongs() -> AnyPublisher<[Song], Error> {
        // Simulate loading local files
    }
    
    func play(song: Song) -> AnyPublisher<Void, Error> {
        // Simulate local playback
    }
    // ... other methods
}
```

### Service Layer

The `MusicPlayerService` provides:

- Singleton access pattern
- Queue management
- Playback state management
- Error handling
- Progress tracking
- Audio session management

### ViewModel Layer

The `MusicPlayerViewModel` handles:

- Data binding with Combine
- UI state management
- User action handling
- Error presentation
- Utility methods for UI

## 🚀 Getting Started

### Prerequisites
- Xcode 14.0+
- iOS 16.0+
- Swift 5.7+

### Installation
1. Clone the repository
2. Open `MusicPlayerServiceDemo.xcodeproj`
3. Build and run the project

### Usage
1. **Select Source**: Choose from Local, Spotify, AudioDB, or Discogs
2. **Browse Library**: View available songs from selected source
3. **Add to Queue**: Tap the + button to add songs to queue
4. **Control Playback**: Use the player controls to play, pause, skip
5. **Manage Queue**: View and manage your playback queue

## 🔌 API Integration

### TheAudioDB API
- Base URL: `https://www.theaudiodb.com/api/v1/json/2`
- Provides music metadata and artwork
- Free to use with API key

### Discogs API
- Base URL: `https://api.discogs.com`
- Provides comprehensive music database
- Requires API key for authentication

## 🧪 Testing

The project includes:
- Unit tests for service layer
- UI tests for user interactions
- Mock implementations for external APIs

## 📈 Extensibility

### Adding New Music Sources

1. Create a new class implementing `MusicSource` protocol
2. Add the source type to `MusicSourceType` enum
3. Update the source selection logic in `LibraryView`
4. Add appropriate icons and colors in `MusicPlayerViewModel`

Example:
```swift
class AppleMusicSource: MusicSource {
    let sourceType: MusicSourceType = .appleMusic
    let displayName: String = "Apple Music"
    
    func loadSongs() -> AnyPublisher<[Song], Error> {
        // Implement Apple Music API integration
    }
    // ... implement other methods
}
```

## 🎯 Design Pattern Benefits

### Singleton Pattern
- **Pros**: Global access, single instance, centralized state
- **Cons**: Can make testing difficult, global state management
- **Use Case**: Perfect for music player service

### Strategy Pattern
- **Pros**: Easy to add new sources, open/closed principle
- **Cons**: Can lead to many classes
- **Use Case**: Multiple music source implementations

### Observer Pattern (Combine)
- **Pros**: Reactive updates, loose coupling, automatic UI updates
- **Cons**: Can be complex to debug, memory management
- **Use Case**: UI state management and data binding

### MVVM Pattern
- **Pros**: Separation of concerns, testable, reusable
- **Cons**: Can be overkill for simple apps
- **Use Case**: Complex UI with business logic

## 🔮 Future Enhancements

- [ ] Real audio playback with AVFoundation
- [ ] Background audio support
- [ ] Audio visualization
- [ ] Playlist management
- [ ] User preferences and settings
- [ ] Offline caching
- [ ] Social features (sharing, recommendations)
- [ ] Voice commands
- [ ] CarPlay integration

## 📄 License

This project is created for educational purposes to demonstrate design patterns and MVVM architecture in Swift.

## 👨‍💻 Author & Trademark

**Created by Hamza Alnasir**  
© 2025 Hamza Alnasir. All rights reserved.

This project is created as part of the Design Patterns Challenge for Music Player Service.

---

*This project demonstrates a comprehensive understanding of design patterns, MVVM architecture, and reactive programming with Combine in Swift.* 