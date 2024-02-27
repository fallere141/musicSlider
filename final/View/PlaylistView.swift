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
//    @State var playlists=[Playlist]()
    @State private var selection = "All"
    var playlists:[Playlist]
    {
        switch selection{
        case "All":
            return musicData.shared.playlist.compactMap({$0})
        default:
            return []
        }
        
        
    }
    
    
    
    
    var body: some View {

        NavigationStack{
            Picker("Select", selection: $selection) {
                Text("All").tag("All")
                Text("Customized").tag("Customized")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            List(playlists){
                playlist in
                NavigationLink(value: playlist){
                HStack{
                    Text(playlist.name)
//                    Text(playlist.id.rawValue)
                    Spacer()
                    AsyncImage(url: playlist.artwork?.url(width: 50, height: 50))
                    {
                        image in image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60,height: 60,alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    
                placeholder: {
                    ProgressView()
                } .frame(width: 75,height: 75,alignment: .center)
                    
                    
                }.onTapGesture {
                    //                    showSongFromPlaylist(playlist: playlist)
                    //                    NavigationLink
                }
            }
                
            }
            .navigationDestination(for: Playlist.self) { item in
                TrackView(playlist: item)
            }.toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if selection != "All" {
                        Button("add playlist") {
                            
                        }
                    }
                    // a transparent button just to make to sections looks the same
                    else{
                        Button("add playlist") {
                            
                        }.opacity(0)
                    }
                }
            }


        }
        

        

    }
    
    
    
    
}

#Preview {
    playListView()
}
