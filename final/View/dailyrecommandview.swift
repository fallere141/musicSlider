//
//  dailyrecommandview.swift
//  final
//
//  Created by Fallere141 on 2/26/24.
//

import SwiftUI
import MusicKit

struct dailyRecommandView: View {
    @State var stations=[Station]()
    @State var song=[Song]()
    var body: some View {
        NavigationView{
            List(stations){
                station in
                HStack{
                    Text(station.name)
                    
                }.onTapGesture {
                }
            }
            
        }.onAppear{
            stations = musicData.shared.recommandStation.compactMap({$0})            
        }
        
    }

    

    

    
}
