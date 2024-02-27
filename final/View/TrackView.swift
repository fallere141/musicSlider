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
            }
            
        }.onAppear{
            
            showSongFromPlaylist()
        }
    }
}

//#Preview {
//    TrackView()
//}
