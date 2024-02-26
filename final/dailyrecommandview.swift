//
//  dailyrecommandview.swift
//  final
//
//  Created by Fallere141 on 2/26/24.
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

struct dailyRecommandView: View {
    @State var songs=[Item]()
    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        NavigationView{
            List(songs){
                song in
                HStack{
                    Text(song.name)
//                    Text(song.artest)
                    Spacer()
                    AsyncImage(url: song.imageURL)
                        .frame(width: 75,height: 75,alignment: .center)
                }.onTapGesture {
//                    NavigationLink
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
    
//    private let request = MusicLibraryRequest<Song>()
    

    
    func fetechData(){
        Task{
           let status = await MusicAuthorization.request()
            switch status{
            case.authorized:
                do{
                    let request = MusicPersonalRecommendationsRequest()
                    let response = try await request.response()
                    let recommendations = response.recommendations
//                    let result = try await request.response()
                    let allStations = recommendations.reduce(into: MusicItemCollection<Station>()) { $0 += $1.stations }
//                    self.songs = allStations
//                    guard let discoveryStation = allStations.first { $0.name == "Discovery Station" } else { return }

//                    print(discoveryStation.debugDescription)
                    
                    self.songs = allStations.compactMap({
                        return .init(name:$0.name,artest:$0.description,imageURL: $0.artwork?.url(width: 75, height: 75))
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
