//
//  musicListView.swift
//  final
//
//  Created by Fallere141 on 2/24/24.
//

import SwiftUI
import MusicKit

//  `musicListView` displays a list of songs, allowing users to mark songs as favorites,
//  and to navigate to a detailed view for each song. It supports dynamic filtering to exclude
//  deleted songs and integrates with a shared global state for navigation and favorite management.
struct musicListView: View {
    @State var songs = [Song]()
    @State var filteredSongs: [Song] = []
    
    @State private var deletedSongs: [Song.ID] = []
    @State private var deletedRecord: [Song.ID] = []
    @State private var favoriteSongs: [Song.ID] = []
    @ObservedObject var globalState: GlobalState
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(filteredSongs.enumerated()), id: \.element.id) { index, song in
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(song.title)
                                    .font(.headline)
                                Button(action: {
                                    musicData.shared.toggleFavorite(song)
                                    favoriteSongs = musicData.shared.favoriteSongs
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
                        AsyncImage(url: song.artwork?.url(width: 60, height: 60)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        } placeholder: {
                            ProgressView()
                        }
                    }.onTapGesture {
                        print(index)
                        globalState.detailViewSongIndex = index
                        print(globalState.detailViewSongIndex)
                        globalState.selectedTab = 0
                    }
                }
            }
            .navigationTitle("Songs")
        }
        
        .onAppear{
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

