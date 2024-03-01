//
//  DetailView.swift
//  final
//
//  Created by Yun Liu on 2/26/24.
//

import SwiftUI
import MusicKit
import Combine

struct DetailView: View {
    @State var songs: [Song] = []
    @State var playlists: [Playlist] = []
    @State var filteredSongs: [Song] = []

    @State private var deletedSongs: [Song.ID] = []
    @State private var favoriteSongs: [Song.ID] = []
    
    @State private var offset = CGSize.zero
    @State private var isRemoved = false
    @State private var showingHelpAlert = false
    @State private var isPlaying = false
    @State private var rotationDegrees = 0.0
    @State private var currentSongIndex = 0
    
    @State private var imageScaleStates: [String: Bool] = [:]

    var rotationTimer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack (alignment: .leading, spacing: 10) {
                    Spacer().frame(height: 70)
                    
                    if filteredSongs.indices.contains(currentSongIndex), let artworkURL = filteredSongs[currentSongIndex].artwork?.url(width: Int(geometry.size.width * 0.8), height: Int(geometry.size.width * 0.8)) {
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
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
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
                                    Task {
                                        await playMusic(filteredSongs[currentSongIndex])
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
                                                if currentSongIndex < filteredSongs.count - 1 {
                                                    currentSongIndex += 1
                                                } else {
                                                    currentSongIndex = 0
                                                }
                                            } else if gesture.translation.width > 50 {
                                                if currentSongIndex > 0 {
                                                    currentSongIndex -= 1
                                                } else {
                                                    currentSongIndex = filteredSongs.count - 1
                                                }
                                            }
                                        }
                                        if isVerticalSwipe {
                                            if gesture.translation.height < -50 {
                                                musicData.shared.markSongAsDeleted(filteredSongs[currentSongIndex])
                                                print(currentSongIndex)
                                                if currentSongIndex > 0 {
                                                    currentSongIndex -= 1
                                                } else {
                                                    currentSongIndex = filteredSongs.count - 2
                                                }
                                                print(currentSongIndex)
                                            } else if gesture.translation.height > 50 {
                                                musicData.shared.toggleFavorite(filteredSongs[currentSongIndex])
                                            }
                                        }
                                    }
                            )
                            .opacity(isRemoved ? 0 : 1)
                            .offset(y: offset.height)
                            .padding(.horizontal, geometry.size.width * 0.05)
                            
                            if !isPlaying {
                                Button(action: {
                                    Task {
                                        await playMusic(filteredSongs[currentSongIndex])
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
                    
                    if filteredSongs.indices.contains(currentSongIndex) {
                        let currentSong = filteredSongs[currentSongIndex]
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
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(musicData.shared.playlist.filter({ musicData.shared.editablePlaylistID.contains($0.id)}).compactMap({$0}), id: \.self) { playlist in
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
                                            let song = filteredSongs[currentSongIndex]
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
                                        }
                                    Spacer().frame(height: 5)
                                    Text("Add playlist")
                                        .font(.caption)
                                        .lineLimit(2)
                                        .frame(height: 40)
                                    
                                    Spacer()
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
                showingHelpAlert = true
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
            .alert(isPresented: $showingHelpAlert) {
                Alert(title: Text("Help"), message: Text("Slide left to switch\n Slide up to delete\n Slide down to like"), dismissButton: .default(Text("OK")))
            }
        }.onAppear{
            songs = musicData.shared.song.compactMap { $0 }
            deletedSongs = musicData.shared.deletedSongs
            filteredSongs = songs.filter { !deletedSongs.contains($0.id) }
            playlists = musicData.shared.playlist.compactMap({$0})

            self.favoriteSongs = musicData.shared.favoriteSongs
        }.onChange(of: musicData.shared.deletedSongs) { _, _ in
            songs = musicData.shared.song.compactMap { $0 }
            deletedSongs = musicData.shared.deletedSongs
            filteredSongs = songs.filter { !deletedSongs.contains($0.id) }
            playlists = musicData.shared.playlist.compactMap({$0})

            self.favoriteSongs = musicData.shared.favoriteSongs
        }.refreshable {
            songs = musicData.shared.song.compactMap { $0 }
            deletedSongs = musicData.shared.deletedSongs
            filteredSongs = songs.filter { !deletedSongs.contains($0.id) }
            playlists = musicData.shared.playlist.compactMap({$0})

            self.favoriteSongs = musicData.shared.favoriteSongs
        }
    }
    
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
    
    func pauseMusic() async {
            ApplicationMusicPlayer.shared.pause()
            isPlaying = false
    }
    
    func addToPlaylist(song: Song, playlist: Playlist) async {
        do {
            let _ = try await MusicLibrary.shared.add(song, to: playlist)
            print("Song \(song.title) was successfully added to the playlist \(playlist.name).")
        } catch {
            debugPrint(error)
        }
    }
}
