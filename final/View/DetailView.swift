//
//  DetailView.swift
//  final
//
//  Created by Yun Liu on 2/26/24.
//

import SwiftUI
import MusicKit
import Combine
import MediaPlayer

/// `DetailView` presents detailed information about a song, including its artwork, title, and artist name.
/// Users can interact with the view to play music, add songs to playlists, and navigate through the song list.
struct DetailView: View {
    @EnvironmentObject var globalState: GlobalState
    
    @State var songs: [Song] = []
    @State var playlists: [Playlist] = []
    @State var filteredSongs: [Song] = []
    
    @State private var deletedSongs: [Song.ID] = []
    @State private var deletedRecord: [Song.ID] = []
    @State private var favoriteSongs: [Song.ID] = []
    
    @State private var offset = CGSize.zero
    @State private var isRemoved = false
    @State private var isPlaying = false
    @State private var rotationDegrees = 0.0
           
    @State private var alertAddMessage = ""
    @State private var showAlertType: AlertType? = nil
    @State private var addingSheet = false
    @State private var userInput = ""
    @State private var detail = ""
    
    enum AlertType: Identifiable {
        case help, error
        
        var id: Int {
            switch self {
            case .help:
                return 0
            case .error:
                return 1
            }
        }
    }
    
    @State private var imageScaleStates: [String: Bool] = [:]

    var rotationTimer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack (alignment: .leading, spacing: 10) {
                    Spacer().frame(height: 40)
                   
                    if filteredSongs.indices.contains(globalState.detailViewSongIndex), let artworkURL = filteredSongs[globalState.detailViewSongIndex].artwork?.url(width: Int(geometry.size.width * 0.8), height: Int(geometry.size.width * 0.8))
                        {
                        ZStack(alignment: .center) {
                            Image("record")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                            
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: geometry.size.width * 0.55, height: geometry.size.width * 0.55)
                            
                            AsyncImage(url: artworkURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geometry.size.width * 0.55, height: geometry.size.width * 0.55)
                                        .clipShape(Circle())
                                case .failure:
                                    Circle()
                                        .foregroundColor(.gray)
                                        .frame(width: geometry.size.width * 0.55, height: geometry.size.width * 0.55)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .rotationEffect(.degrees(rotationDegrees))
                            .onReceive(rotationTimer) { _ in
                                if isPlaying {
                                    rotationDegrees += 0.3
                                    if rotationDegrees >= 360 {
                                        rotationDegrees = 0
                                    }
                                }
                            }
                            .onTapGesture {
                                if isPlaying {
                                    Task {
                                        await pauseMusic()
                                    }
                                } else {
                                    let currentSong = filteredSongs[globalState.detailViewSongIndex]
                                    Task {
                                        await playMusic(currentSong)
                                    }
                                }
                            }
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        if abs(gesture.translation.height) > abs(gesture.translation.width) {
                                            self.offset.height = gesture.translation.height
                                        }
                                    }
                                    .onEnded { gesture in
                                        withAnimation {
                                            self.offset = .zero
                                        }
                                        let isHorizontalSwipe = abs(gesture.translation.width) > abs(gesture.translation.height)
                                        let isVerticalSwipe = !isHorizontalSwipe
                                        if isHorizontalSwipe {
                                            if gesture.translation.width < -50 {
                                                if globalState.detailViewSongIndex < filteredSongs.count - 1 {
                                                    globalState.detailViewSongIndex += 1
                                                } else {
                                                    globalState.detailViewSongIndex = 0
                                                }
                                            } else if gesture.translation.width > 50 {
                                                if globalState.detailViewSongIndex > 0 {
                                                    globalState.detailViewSongIndex -= 1
                                                } else {
                                                    globalState.detailViewSongIndex = filteredSongs.count - 1
                                                }
                                            }
                                        }
                                        if isVerticalSwipe {
                                            if gesture.translation.height < -50 {
                                                musicData.shared.markSongAsDeleted(filteredSongs[globalState.detailViewSongIndex])
                                                print(globalState.detailViewSongIndex)
                                                if globalState.detailViewSongIndex > 0 {
                                                    globalState.detailViewSongIndex -= 1
                                                } else {
                                                    globalState.detailViewSongIndex = filteredSongs.count - 2
                                                }
                                                print(globalState.detailViewSongIndex)
                                            } else if gesture.translation.height > 50 {
                                                musicData.shared.toggleFavorite(filteredSongs[globalState.detailViewSongIndex])
                                            }
                                        }
                                    }
                            )
                            .opacity(isRemoved ? 0 : 1)
                            .offset(y: offset.height)
                            .padding(.horizontal, geometry.size.width * 0.05)
                            
                            if !isPlaying {
                                Button(action: {
                                    let currentSong = filteredSongs[globalState.detailViewSongIndex]
                                    Task {
                                        await playMusic(currentSong)
                                    }
                                }) {
                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .foregroundColor(.white)
                                        .frame(width: 100, height: 100)
                                        .opacity(0.5)
                                }
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)
                    } else {
                        ZStack(alignment: .center) {
                            Image("record")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                            
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: geometry.size.width * 0.55, height: geometry.size.width * 0.55)
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)
                    }
                    
                    Spacer().frame(height: 20)
                    
                    if filteredSongs.indices.contains(globalState.detailViewSongIndex) {
                        let currentSong = filteredSongs[globalState.detailViewSongIndex]
                        Text(currentSong.title)
                            .font(.system(size: 28))
                            .bold()
                            .padding(.leading)
                            .lineLimit(2)
                            .frame(height: 70)
                        Text(currentSong.artistName)
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                            .padding(.leading)
                            .frame(height: 20)
                    } else {
                        Text("")
                            .frame(height: 70)
                        Text("")
                            .frame(height: 20)
                    }
                    

                    Spacer().frame(height: 15)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Save to playlist ...")
                            .font(.subheadline)
                            .padding(.horizontal)
                        
                        var sortedPlaylists: [Playlist] {
                            musicData.shared.playlist.compactMap({$0}).sorted { (playlist1, playlist2) -> Bool in
                                let date1 = playlist1.lastModifiedDate ?? Date.distantPast
                                let date2 = playlist2.lastModifiedDate ?? Date.distantPast
                                return date1 > date2
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {

                                ForEach(musicData.shared.playlist.filter({ musicData.shared.editablePlaylistID.contains($0.id)}).compactMap({$0}), id: \.self) { playlist in
//                              Use this line if you want to display all playlists in the detailedView
//                                ForEach( sortedPlaylists, id: \.self) { playlist in

                                    VStack(alignment: .center, spacing: 5) {
                                        AsyncImage(url: playlist.artwork?.url(width: 50, height: 50)) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        } placeholder: {
                                            Image(systemName: "arrow.down")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .scaleEffect(imageScaleStates[playlist.id.rawValue, default: false] ? 0.8 : 1)
                                        .animation(.easeInOut(duration: 0.2), value: imageScaleStates[playlist.id.rawValue, default: false])
                                        .onTapGesture {
                                            imageScaleStates[playlist.id.rawValue] = true
                                            let song = filteredSongs[globalState.detailViewSongIndex]
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                imageScaleStates[playlist.id.rawValue] = false
                                            }
                                            Task{
                                                await addToPlaylist(song: song, playlist: playlist)
                                                imageScaleStates[playlist.id.rawValue] = false
                                                
                                            }
                                        }
                                        
                                        Text(playlist.name)
                                            .font(.caption)
                                            .lineLimit(2)
                                            .frame(height: 40)
                                        
                                        Spacer()
                                    }
                                    .frame(width: 60, height: 100, alignment: .top)
                                }
                                VStack(alignment: .center, spacing: 5) {
                                    Spacer().frame(height: 15)
                                    Image(systemName: "ellipsis")

                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.gray)
                                        .onTapGesture {
//                                            addNewPlaylist()
                                            addingSheet.toggle()
                                        }
                                    Spacer().frame(height: 5)
                                    Text("Add playlist")
                                        .font(.caption)
                                        .lineLimit(2)
                                        .frame(height: 40)
                                    
                                    Spacer()
                                }.onTapGesture{
//                                    addingSheet.toggle()
                                }
                                .frame(width: 60, height: 100, alignment: .top)
                                
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 100)
                        
                    }
                }
            }
            .navigationBarItems(leading: Button(action: {
                showAlertType = .help
            }) {
                Image(systemName: "info.circle")
                    .imageScale(.large)
                    .accessibilityLabel(Text("Help"))
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: DeleteView()) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "trash")
                            
                            if !musicData.shared.deletedSongs.isEmpty {
                                Text("\(musicData.shared.deletedSongs.count)")
                                    .font(.caption2)
                                    .padding(5)
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.red))
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
            }
            .alert(item: $showAlertType) { alertType in
                switch alertType {
                case .help:
                    return Alert(title: Text("Help"), message: Text("Slide left to switch\n Slide up to delete\n Slide down to like"), dismissButton: .default(Text("OK")))
                case .error:
                    return Alert(title: Text("Error"), message: Text("An error occurred!"), dismissButton: .default(Text("OK")))
                }
            }
        }.sheet(isPresented: $addingSheet) {
            FormView(addingSheet: $addingSheet,userInput: $userInput,detail:$detail)
        }.onAppear{
            self.songs = musicData.shared.song.compactMap { $0 }
            self.deletedSongs = musicData.shared.deletedSongs
            self.deletedRecord = musicData.shared.deletedRecord
            self.filteredSongs = self.songs.filter { song in
                !(self.deletedSongs.contains(song.id) || self.deletedRecord.contains(song.id))
            }
            self.favoriteSongs = musicData.shared.favoriteSongs
            self.playlists = musicData.shared.playlist.compactMap({$0})
        }.onChange(of: musicData.shared.deletedSongs) { _, _ in
            self.songs = musicData.shared.song.compactMap { $0 }
            self.deletedSongs = musicData.shared.deletedSongs
            self.deletedRecord = musicData.shared.deletedRecord
            self.filteredSongs = self.songs.filter { song in
                !(self.deletedSongs.contains(song.id) || self.deletedRecord.contains(song.id))
            }
            self.favoriteSongs = musicData.shared.favoriteSongs
            self.playlists = musicData.shared.playlist.compactMap({$0})
        }.onChange(of: musicData.shared.song) { _, _ in
            self.songs = musicData.shared.song.compactMap { $0 }
            self.deletedSongs = musicData.shared.deletedSongs
            self.deletedRecord = musicData.shared.deletedRecord
            self.filteredSongs = self.songs.filter { song in
                !(self.deletedSongs.contains(song.id) || self.deletedRecord.contains(song.id))
            }
            self.favoriteSongs = musicData.shared.favoriteSongs
            self.playlists = musicData.shared.playlist.compactMap({$0})
        }.onChange(of: musicData.shared.deletedRecord) { _, _ in
            self.songs = musicData.shared.song.compactMap { $0 }
            self.deletedSongs = musicData.shared.deletedSongs
            self.deletedRecord = musicData.shared.deletedRecord
            self.filteredSongs = self.songs.filter { song in
                !(self.deletedSongs.contains(song.id) || self.deletedRecord.contains(song.id))
            }
            self.favoriteSongs = musicData.shared.favoriteSongs
            self.playlists = musicData.shared.playlist.compactMap({$0})
        }.refreshable {
            self.songs = musicData.shared.song.compactMap { $0 }
            self.deletedSongs = musicData.shared.deletedSongs
            self.deletedRecord = musicData.shared.deletedRecord
            self.filteredSongs = self.songs.filter { song in
                !(self.deletedSongs.contains(song.id) || self.deletedRecord.contains(song.id))
            }
            self.favoriteSongs = musicData.shared.favoriteSongs
            self.playlists = musicData.shared.playlist.compactMap({$0})
        }
    }
    
    /// Plays the selected song using `ApplicationMusicPlayer`.
    /// - Parameter song: The `Song` object to be played.
    func playMusic(_ song: Song) async {
        do {
            ApplicationMusicPlayer.shared.queue = [song]
            try await ApplicationMusicPlayer.shared.play()
            isPlaying = true
        } catch {
            debugPrint(error)
            isPlaying = false
        }
    }
    
    /// Pauses the currently playing song.
    func pauseMusic() async {
            ApplicationMusicPlayer.shared.pause()
            isPlaying = false
    }
    
    /// Adds a song to a specified playlist.
    func addToPlaylist(song: Song, playlist: Playlist) async {
        do {
            let _ = try await MusicLibrary.shared.add(song, to: playlist)
            print("Song \(song.title) was successfully added to the playlist \(playlist.name).")
        } catch {
            print("Failed to add song to playlist: \(error.localizedDescription)")

            self.showAlertType = .error
            self.alertAddMessage = "This playlist is Public"
        }
    }
}
