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
    @State var song=[Song]()
    var body: some View {
//        Text("count\(stations.count)")
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
//            Text(stations.first.name)
            
        }.onAppear{
            stations = musicData.shared.recommandStation.compactMap({$0})
            
//            song = stations[0]
        }
        
    }

    

    

    
}
