//
//  ContentView.swift
//  final
//
//  Created by Fallere141 on 2/24/24.
//

import SwiftUI

struct ContentView: View {

    @State var musicdata = musicData.shared
    @EnvironmentObject var globalState: GlobalState

    var body: some View {
        TabView(selection: $globalState.selectedTab) {
            DetailView()
                .tabItem {
                    Label("Slider", systemImage: "music.note")
                }.tag(0)
                .environmentObject(globalState)
            
            playListView()
                .tabItem {
                    Label("Playlist", systemImage: "music.note.list")
                }.tag(1)
            
            musicListView(globalState: globalState)
                .tabItem {
                    Label("Music Library", systemImage: "music.house")
                }.tag(2)
            
            dailyRecommandView()
                .tabItem {
                    Label("Daily for U", systemImage: "music.quarternote.3")
                }.tag(3)
        }.environmentObject(globalState)
    }
}


#Preview {
    ContentView()
}
