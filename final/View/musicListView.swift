//
//  musicListView.swift
//  final
//
//  Created by Fallere141 on 2/24/24.
//

import SwiftUI
import MusicKit
//struct Item:Identifiable,Codable{
//    var id=UUID()
//    let name:String
//    let artest:String
//    let imageURL:URL?
//    
//    
//}

struct musicListView: View {
    @State var songs = [Song]()
    @State var filteredSongs: [Song] = []
    @State private var deletedSongs: [Song.ID] = []
    
    var body: some View {

        NavigationView{
            List(filteredSongs){
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
                    {image in image
                            .resizable()
                            .frame(width: 60,height: 60,alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                placeholder: {
                    ProgressView()
                }
                        

                }.onTapGesture {
                    
                }
            }
            
        }.onAppear{
            songs = musicData.shared.song.compactMap { $0 }
            deletedSongs = musicData.shared.deletedSongs
            filteredSongs = songs.filter { !deletedSongs.contains($0.id) }
        }.onChange(of: musicData.shared.deletedSongs) { _, _ in
            songs = musicData.shared.song.compactMap { $0 }
            deletedSongs = musicData.shared.deletedSongs
            filteredSongs = songs.filter { !deletedSongs.contains($0.id) }
        }.refreshable {
            songs = musicData.shared.song.compactMap { $0 }
            deletedSongs = musicData.shared.deletedSongs
            filteredSongs = songs.filter { !deletedSongs.contains($0.id) }
        }
    }
    
    
}

#Preview {
    musicListView()
}
