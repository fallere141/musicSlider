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
    var body: some View {

        NavigationView{
            List(songs){
                song in
                HStack{
                    Text(song.title)
                    Spacer()
                    Text(song.artistName)
                    Spacer()
                    AsyncImage(url: song.artwork?.url(width: 75, height: 75)){_ in }
                placeholder: {
                    ProgressView()
                }
                        .frame(width: 75,height: 75,alignment: .center)

                }.onTapGesture {
                    
                }
            }
            
        }.onAppear{
//            songs = musicData.shared.song.compactMap({
//                .init(name:$0.title,artest:$0.artistName,imageURL: $0.artwork?.url(width: 75, height: 75))
//            })
            songs = musicData.shared.song.compactMap({$0})
        }
    }
    
    
}

#Preview {
    musicListView()
}
