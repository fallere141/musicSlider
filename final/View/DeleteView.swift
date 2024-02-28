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
                }
            }
            .navigationTitle("Deleted Songs")
            .toolbar {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                }
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Confirm Delete"),
                    message: Text("Are you sure you want to permanently delete these songs?"),
                    primaryButton: .destructive(Text("Delete")) {
//                        musicData.shared.deleteListSongs()
                    },
                    secondaryButton: .cancel()
                )
            }
        }.onAppear{
            songs = musicData.shared.song.compactMap({$0})
            self.deletedSongs = songs.filter { musicData.shared.deletedSongs.contains($0.id) }
        }
    }

    
}

#Preview {
    DeleteView()
}
