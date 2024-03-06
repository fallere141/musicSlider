//
//  SwiftUIView.swift
//  final
//
//  Created by Fallere141 on 2/27/24.
//

import SwiftUI
import MusicKit

/// `TrackView` displays a list of tracks from a given playlist.
struct TrackView: View {
    @State var playlist: Playlist
    @State var trackList:[Track] = []
    @ObservedObject var globalState: GlobalState
    @State private var deletedSongs: [Song.ID] = []
    @State private var deletedRecord: [Song.ID] = []
    @State var filteredSongs: [Song] = []
    @State var songs = [Song]()
    @State private var favoriteSongs: [Song.ID] = []
    @State var showingHelpAlert = false
    
    /// Fetches tracks from the specified playlist and updates the `trackList` state.
    func showSongFromPlaylist(){
        Task{
            let detailedPlaylist = try await playlist.with([.tracks])
            let tracks = detailedPlaylist.tracks ?? []
            trackList = tracks.compactMap({$0})
        }
    }
    
    /// Deletes a specified track from the playlist.
    func deleteSongFromPlaylist(track:Track){
        Task{
            do{
                try await MusicLibrary.shared.edit(playlist, items: trackList.filter({!($0.id==track.id)}))
            }catch{
                return
            }
        }
    }
    
    var body: some View {
        NavigationView{
            List(trackList){
                song in
                HStack{
                    VStack(alignment: .leading) {
                        HStack{
                            Text(song.title)
                                .font(.headline)
                            
                            Button(action: {
                                if let index = filteredSongs.firstIndex(where: { $0.id.rawValue == song.id.rawValue }){
                                    musicData.shared.toggleFavorite(filteredSongs[index])
                                    favoriteSongs = musicData.shared.favoriteSongs
                                }else{
                                    
                                }
                            }) {
                                Image(systemName: favoriteSongs.contains(song.id) ? "heart.fill" : "heart")
                                    .foregroundColor(.gray)
                            }
                            
                        }
                        Text(song.artistName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                    }
                    
                    Spacer()
                    AsyncImage(url: song.artwork?.url(width: 60, height: 60))
                    {
                        image in image
                            .resizable()
                            .frame(width: 60,height: 60,alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    placeholder: {
                        ProgressView()
                    }
                }.onTapGesture {
                    if let index = filteredSongs.firstIndex(where: { $0.id.rawValue == song.id.rawValue })
                        {
                            print(index)
                            globalState.detailViewSongIndex = index
                            print(globalState.detailViewSongIndex)
                            globalState.selectedTab = 0
                        }
                        else{
                            showingHelpAlert.toggle()
                            
                        }

                }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if(musicData.shared.editablePlaylistID.contains(playlist.id))
                        {
                            Button(role: .destructive) {
                                print(song)
                                deleteSongFromPlaylist(track: song)
                            } label: {
                                Label("Recover", systemImage: "trash")
                            }
                        }
                }
                    .alert(isPresented: $showingHelpAlert) {
                        Alert(title: Text("This song is already deleted"), message: Text("If you want to listen this song, please remove it from deleted songs."), dismissButton: .default(Text("OK")))
                    }
            }
            
        }      
        .onAppear{
            showSongFromPlaylist()
            songs = musicData.shared.song.compactMap { $0 }
            deletedSongs = musicData.shared.deletedSongs
            favoriteSongs = musicData.shared.favoriteSongs
            deletedRecord = musicData.shared.deletedRecord
            filteredSongs = songs.filter { song in
                !deletedSongs.contains(song.id) && !deletedRecord.contains(song.id)
            }
        }.onChange(of: musicData.shared.deletedSongs) { _, _ in
            songs = musicData.shared.song.compactMap { $0 }
            deletedSongs = musicData.shared.deletedSongs
            favoriteSongs = musicData.shared.favoriteSongs
            deletedRecord = musicData.shared.deletedRecord
            filteredSongs = songs.filter { song in
                !deletedSongs.contains(song.id) && !deletedRecord.contains(song.id)
            }
        }.refreshable {
            songs = musicData.shared.song.compactMap { $0 }
            deletedSongs = musicData.shared.deletedSongs
            favoriteSongs = musicData.shared.favoriteSongs
            deletedRecord = musicData.shared.deletedRecord
            filteredSongs = songs.filter { song in
                !deletedSongs.contains(song.id) && !deletedRecord.contains(song.id)
            }
        }
    }
}

//#Preview {
//    TrackView()
//}
