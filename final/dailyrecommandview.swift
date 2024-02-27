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
    @State var stations=[Station]()
    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        NavigationView{
            List(stations){
                station in
                HStack{
                    Text(station.name)
//                    Text(song.artest)
                    
                }.onTapGesture {
//                    NavigationLink
                }
            }
            
        }.onAppear{
            
        }
    }
//    private let request : MusicCatalogSearchRequest = {
//        var request = MusicCatalogSearchRequest(term: "happy", types: [Song.self])
//        request.limit = 25
//        return request
//    }()
    
//    private let request = MusicLibraryRequest<Song>()
    

    

    
}

#Preview {
    musicListView()
}
