import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MusicPlayerViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlayerView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "music.note")
                    Text("Player")
                }
                .tag(0)
            
            QueueView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Queue")
                }
                .tag(1)
            
            LibraryView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Library")
                }
                .tag(2)
            
            SettingsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}

// MARK: - Player View
struct PlayerView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Source Info
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.blue)
                    Text(viewModel.currentSourceName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("™ Hamza Alnasir")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                }
                .padding(.horizontal)
                
                // Album Art Placeholder
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 250, height: 250)
                    .overlay(
                        VStack {
                            Image(systemName: "music.note")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Album Art")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
                
                // Song Info
                VStack(spacing: 8) {
                    Text(viewModel.currentSongTitle)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text(viewModel.currentArtist)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.currentAlbum)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Progress Bar
                VStack(spacing: 8) {
                    ProgressView(value: viewModel.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    HStack {
                        Text(viewModel.currentTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(viewModel.totalTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Control Buttons
                HStack(spacing: 40) {
                    Button(action: viewModel.previous) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: viewModel.playPauseToggle) {
                        Image(systemName: viewModel.getPlaybackStateIcon())
                            .font(.system(size: 50))
                            .foregroundColor(viewModel.getPlaybackStateColor())
                    }
                    
                    Button(action: viewModel.skip) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                
                // Stop Button
                Button(action: viewModel.stop) {
                    Text("Stop")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .cornerRadius(25)
                }
                
                Spacer()
            }
            .navigationTitle("Now Playing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Queue View
struct QueueView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(viewModel.queueItems.enumerated()), id: \.element.id) { index, item in
                    QueueItemRow(
                        item: item,
                        isCurrentSong: viewModel.isCurrentSong(item.song),
                        isPlaying: viewModel.isPlaying,
                        onTap: {
                            viewModel.playSong(at: index)
                        },
                        onRemove: {
                            viewModel.removeFromQueue(at: index)
                        }
                    )
                }
                .onMove(perform: moveQueueItems)
            }
            .navigationTitle("Queue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        viewModel.clearQueue()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func moveQueueItems(from source: IndexSet, to destination: Int) {
        // This would need to be implemented in the ViewModel
        // For now, just a placeholder
    }
}

// MARK: - Queue Item Row
struct QueueItemRow: View {
    let item: QueueItem
    let isCurrentSong: Bool
    let isPlaying: Bool
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.song.title)
                    .font(.headline)
                    .foregroundColor(isCurrentSong ? .blue : .primary)
                
                Text(item.song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let album = item.song.album {
                    Text(album)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isCurrentSong {
                Image(systemName: isPlaying ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .foregroundColor(.blue)
            }
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Library View
struct LibraryView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @State private var selectedSource: MusicSourceType = .local
    
    var body: some View {
        NavigationView {
            VStack {
                // Source Picker
                Picker("Source", selection: $selectedSource) {
                    ForEach(MusicSourceType.allCases, id: \.self) { source in
                        Text(source.rawValue).tag(source)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: selectedSource) { newSource in
                    switch newSource {
                    case .local:
                        viewModel.setSource(LocalMusicSource())
                    case .spotify:
                        viewModel.setSource(SpotifyMusicSource())
                    case .audioDB:
                        viewModel.setSource(AudioDBMusicSource())
                    case .discogs:
                        viewModel.setSource(DiscogsMusicSource())
                    }
                }
                
                // Songs List
                List(viewModel.availableSongs, id: \.id) { song in
                    SongRow(
                        song: song,
                        isCurrentSong: viewModel.isCurrentSong(song),
                        onTap: {
                            viewModel.addToQueue(song)
                        }
                    )
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Song Row
struct SongRow: View {
    let song: Song
    let isCurrentSong: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .foregroundColor(isCurrentSong ? .blue : .primary)
                
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(song.source.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    
                    Text(formatDuration(song.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onTap) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .contentShape(Rectangle())
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Player Information")) {
                    HStack {
                        Text("Current Source")
                        Spacer()
                        Text(viewModel.currentSourceName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Queue Length")
                        Spacer()
                        Text("\(viewModel.queueItems.count) songs")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Available Songs")
                        Spacer()
                        Text("\(viewModel.availableSongs.count) songs")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Playback Controls")) {
                    Button("Play/Pause") {
                        viewModel.playPauseToggle()
                    }
                    
                    Button("Skip") {
                        viewModel.skip()
                    }
                    
                    Button("Previous") {
                        viewModel.previous()
                    }
                    
                    Button("Stop") {
                        viewModel.stop()
                    }
                }
                
                Section(header: Text("Queue Management")) {
                    Button("Clear Queue") {
                        viewModel.clearQueue()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "c.circle.fill")
                                .foregroundColor(.blue)
                            Text("Music Player Service")
                                .font(.headline)
                        }
                        
                        Text("Design Patterns Challenge")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("A comprehensive music player demonstrating MVVM architecture and design patterns with Combine for reactive data communication.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        HStack {
                            Image(systemName: "trademark")
                                .foregroundColor(.orange)
                            Text("Created by Hamza Alnasir")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Text("© 2025 Hamza Alnasir. All rights reserved.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
