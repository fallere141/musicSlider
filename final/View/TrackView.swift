//
//  SwiftUIView.swift
//  final
//
//  Created by Fallere141 on 2/27/24.
//

import SwiftUI
import MusicKit

struct TrackView: View {
    @State var playlist: Playlist
    @State var trackList:[Track] = []
    
    func showSongFromPlaylist(){
        Task{
            let detailedPlaylist = try await playlist.with([.tracks])
            let tracks = detailedPlaylist.tracks ?? []
            trackList = tracks.compactMap({$0})
        }
    }
    
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
                        Text(song.title)
                            .font(.headline)
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
                }
//                (musicData.shared.editablePlaylistID.contains(playlist.id))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if(musicData.shared.editablePlaylistID.contains(playlist.id))
                        {
                            Button(role: .destructive) {
                                print(song)
                                deleteSongFromPlaylist(track: song)
                            } label: {
                                Label("Recover", systemImage: "square.and.arrow.up")
                            }
                        }
                }
//                }
            }
            
        }.onAppear{
            
            showSongFromPlaylist()
        }
    }
}

//#Preview {
//    TrackView()
//}
