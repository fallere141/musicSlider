//
//  DeleteView.swift
//  final
//
//  Created by Yun Liu on 2/27/24.
//

import SwiftUI
import MusicKit

struct DeleteView: View {
    @State var songs: [Song] = []
    @State var deletedSongs = [Song]()
    
    @State private var showingDeleteAlert = false
    @State private var showingRecoverAllAlert = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(deletedSongs, id: \.id) { song in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(song.title)
                                .font(.headline)
                            Text(song.artistName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        AsyncImage(url: song.artwork?.url(width: 60, height: 60)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                     .frame(width: 60, height: 60)
                                     .clipShape(RoundedRectangle(cornerRadius: 5))
                            case .failure(_):
                                Image(systemName: "music.note")
                                     .frame(width: 60, height: 60)
                            default:
                                ProgressView()
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            musicData.shared.removeSongFromDeleted(songId: song.id)
                        } label: {
                            Label("Recover", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .navigationTitle("Deleted Songs")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        showingRecoverAllAlert = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Confirm Delete"),
                    message: Text("Are you sure you want to permanently delete these songs?"),
                    primaryButton: .destructive(Text("Delete")) {
                        musicData.shared.deleteListSongs()
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert("Confirm Recover", isPresented: $showingRecoverAllAlert, presenting: deletedSongs) { _ in
                Button("Recover All", role: .destructive) {
                    musicData.shared.recoverAllDeletedSongs()
                }
                Button("Cancel", role: .cancel) { }
            } message: { _ in
                Text("Are you sure you want to recover all deleted songs?")
            }
        }.onAppear{
            songs = musicData.shared.song.compactMap({$0})
            self.deletedSongs = songs.filter { musicData.shared.deletedSongs.contains($0.id) }
        }.onChange(of: musicData.shared.deletedSongs) { _, _ in
            songs = musicData.shared.song.compactMap({$0})
            self.deletedSongs = songs.filter { musicData.shared.deletedSongs.contains($0.id) }
        }
    }



}

#Preview {
    DeleteView()
}
