//
//  PlaylistView.swift
//  final
//
//  Created by Fallere141 on 2/26/24.
//


import SwiftUI
import MusicKit


struct playListItem:Identifiable,Codable{
    var id=UUID()
    let name:String
    let curator:String?

    
    
}

struct playListView: View {
    @State var playlists=[playListItem]()
    var body: some View {

        NavigationView{
            List(playlists){
                playlist in
                HStack{
                    Text(playlist.name)
                    
                    Text(playlist.curator ?? "no curator")
                }

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
    
    private let request = MusicLibraryRequest<Playlist>()
//    private let request = MusicLibrarySearchRequest(term: "fa", types: [Playlist.self])
    
    func fetechData(){
        Task{
           let status = await MusicAuthorization.request()
            switch status{
            case.authorized:
                do{
                    let result = try await request.response()
                    
                    self.playlists = result.items.compactMap({
                        return .init(name: $0.name, curator: $0.curatorName)
                    })
                    
//                    self.playlists = result.playlists.compactMap({
//                        return .init(name: $0.name, curator: $0.curatorName)
//                    })
//
                }catch{
                    
                }
            default:
                break
            }
        }
    }
    
}

#Preview {
    playListView()
}
