//
//  musicListView.swift
//  final
//
//  Created by Fallere141 on 2/24/24.
//

import SwiftUI
import MusicKit
struct Item:Identifiable,Codable{
    var id=UUID()
    let name:String
    let artest:String
    let imageURL:URL?
    
    
}

struct musicListView: View {
    @State var songs=[Item]()
    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        NavigationView{
            List(songs){
                song in
                Text(song.name)
                Text(song.artest)
                AsyncImage(url: song.imageURL)
                    .frame(width: 75,height: 75,alignment: .center)
            }
            
        }.onAppear{
            fetechData()
        }
    }
//    private let request : MusicCatalogSearchRequest = {
//        var request = MusicCatalogSearchRequest(term: "happy", types: [Song.self])
//        request.limit = 25
//        return request
//    }()
    
    private let request = MusicLibraryRequest<Song>()
    
    func fetechData(){
        Task{
           let status = await MusicAuthorization.request()
            switch status{
            case.authorized:
                do{
                    let result = try await request.response()
                    
                    self.songs = result.items.compactMap({
                        return .init(name:$0.title,artest:$0.artistName,imageURL: $0.artwork?.url(width: 75, height: 75))
                    })
//                    self.songs = result.songs.compactMap({
//                        return .init(name:$0.title,artest:$0.artistName,imageURL: $0.artwork?.url(width: 75, height: 75))
//                    })
                }catch{
                    
                }
            default:
                break
            }
        }
    }
    
}

#Preview {
    musicListView()
}
