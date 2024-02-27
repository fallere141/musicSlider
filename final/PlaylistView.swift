//
//  PlaylistView.swift
//  final
//
//  Created by Fallere141 on 2/26/24.
//


import SwiftUI
import MusicKit


//struct playListItem:Identifiable,Codable{
//    var id=UUID()
//    let name:String
//    let playlist:Playlist
//
//
//
//}

struct playListView: View {
    @State var playlists=[Playlist]()
    var body: some View {
        
        NavigationView{
            List(playlists){
                playlist in
                HStack{
                    Text(playlist.name)
                    
                    AsyncImage(url: playlist.artwork?.url(width: 75, height: 75))
                    {_ in }
                placeholder: {
                    ProgressView()
                }
                .frame(width: 75,height: 75,alignment: .center)

                }
                
            }
            
        }.onAppear{
            //            fetechData()
            //            playlists = Array(from: musicData.shared.playlist)
            playlists = musicData.shared.playlist.compactMap({$0})
        }
    }
    
    
    
    
}

#Preview {
    playListView()
}
