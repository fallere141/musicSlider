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
    
    @State private var offset = CGSize.zero
    @State private var isRemoved = false
    @State private var showingHelpAlert = false
    @State private var isPlaying = false
    @State private var rotationDegrees = 0.0
    var rotationTimer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack (alignment: .leading, spacing: 10) {
                    Spacer().frame(height: 100)
                    
                    if let firstSong = songs.first, let artworkURL = firstSong.artwork?.url(width: Int(geometry.size.width * 0.8), height: Int(geometry.size.width * 0.8)) {
                        ZStack(alignment: .center) {
                            //                            Circle()
                            //                                .foregroundColor(.gray.opacity(0.8))
                            //                                .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                            
                            Image("record")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                            
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
                                        await playMusic(songs.first!)
                                    }
                                }
                            }
                            //                            .gesture(
                            //                                DragGesture()
                            //                                    .onChanged { gesture in
                            //                                        self.offset = gesture.translation
                            //                                    }
                            //                                    .onEnded { gesture in
                            //                                        handleGestureEnd(gesture)
                            //                                    }
                            //                            )
                            .opacity(isRemoved ? 0 : 1)
                            .offset(y: offset.height)
                            .padding(.horizontal, geometry.size.width * 0.05)
                            
                            
                            if !isPlaying {
                                Button(action: {
                                    Task {
                                        await playMusic(firstSong)
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
                        Image(systemName: "music.note")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                    }
                    
                    Spacer().frame(height: 20)
                    
                    if let firstSong = songs.first {
                        let artistName = firstSong.artistName
                        Text(firstSong.title)
                            .font(.title)
                            .padding(.leading)
                        Text(artistName)
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.leading)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(playlists, id: \.self) { playlist in
                                VStack {
                                    Image(systemName: "arrow.down.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    
                                    Text(playlist.name)
                                        .font(.caption)
                                }
                                .frame(width: 120, height: 150)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 150)
                    
                }
            }
            .navigationBarItems(leading: Button(action: {
                showingHelpAlert = true
            }) {
                Image(systemName: "info.circle")
                    .imageScale(.large)
                    .accessibilityLabel(Text("Help"))
            })
            .alert(isPresented: $showingHelpAlert) {
                Alert(title: Text("Help"), message: Text("Slide left to switch\n Slide up to delete\n Slide down to like"), dismissButton: .default(Text("OK")))
            }
        }.onAppear{
            songs = musicData.shared.song.compactMap({$0})
            playlists = musicData.shared.playlist.compactMap({$0})
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
}




//import SwiftUI
//import MusicKit
//
//struct DetailView: View {
//    @State var song = [Song]()
//    @State private var offset = CGSize.zero
//    @State private var isRemoved = false
//    @State private var showingHelpAlert = false
//    
//    var body: some View {
//        NavigationView {
//            GeometryReader { geometry in
//                VStack {
//                    AsyncImage(url: song.artwork?.url) { phase in
//                        switch phase {
//                        case .empty:
//                            ProgressView()
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .scaledToFit()
//                        case .failure:
//                            Image(systemName: "photo")
//                                .resizable()
//                                .scaledToFit()
//                        @unknown default:
//                            EmptyView()
//                        }
//                    }
//                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
//                    .opacity(isRemoved ? 0 : 1)
//                    .offset(y: offset.height)
//                    .animation(.easeInOut, value: offset)
//                    .gesture(
//                        DragGesture()
//                            .onChanged { gesture in
//                                self.offset = gesture.translation
//                            }
//                            .onEnded { gesture in
//                                handleGestureEnd(gesture)
//                            }
//                    )
//                    .onChange(of: song) { _ in
//                        self.offset = .zero
//                        self.isRemoved = false
//                    }
//                    
                    
                    

            
//                }
//            }
//            .navigationBarItems(leading: Button(action: {
//                showingHelpAlert = true
//            }) {
//                Text("Help")
//            })
//            .alert(isPresented: $showingHelpAlert) {
//                Alert(title: Text("Help"), message: Text("Slide left to switch，Slide up to detete，Slide down to like"), dismissButton: .default(Text("OK")))
//            }
//            .navigationBarTitle("ImageSlider", displayMode: .inline)
//        }
//    }
    
//    private func handleGestureEnd(_ gesture: DragGesture.Value) {
//        let horizontalAmount = gesture.translation.width
//        let verticalAmount = gesture.translation.height
//        
//        let nextSong = determineNextSong()
//        
//        if abs(horizontalAmount) > abs(verticalAmount) {
//            if horizontalAmount < 0 {
//                withAnimation {
//                    isRemoved = true
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//                    self.song = nextSong
//                }
//            } else {
//                //switch to previous song
//            }
//        } else {
//            if verticalAmount < 0 {
//                withAnimation {
//                    isRemoved = true
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//                    musicData.deleteItem(item!)
//                    self.song = nextSong
//                }
//            } else {
//                dataModel.toggleFavorite(item!)
//            }
//        }
//        
//        self.offset = .zero
//    }
//
//    private func determineNextSong() -> Song {
//        guard let currentIndex = musicData.songs.firstIndex(where: { $0.id == self.song!.id }) else {
//            return self.song!
//        }
//        
//        let nextIndex = currentIndex + 1 < musicData.songs.count ? currentIndex + 1 : 0
//        return musicData.songs[nextIndex]
//    }
//}



