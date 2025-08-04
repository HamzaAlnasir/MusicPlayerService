import SwiftUI

@main
struct MusicPlayerServiceApp: App {
    @StateObject private var playerService = MusicPlayerService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Initialize with local music source by default
                    if playerService.currentSource == nil {
                        playerService.setSource(LocalMusicSource())
                    }
                }
        }
    }
}
