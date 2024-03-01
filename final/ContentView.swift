//
//  ContentView.swift
//  final
//
//  Created by Fallere141 on 2/24/24.
//

import SwiftUI

struct ContentView: View {
    @State var musicdata = musicData.shared
    
    var body: some View {
        TabView {
            // Update to DetailView Later
            DetailView()
                .tabItem {
                    Label("Slider", systemImage: "music.note") }
            playListView()
                .tabItem {
                    Label("Playlist", systemImage: "music.note.list") }
            musicListView()
                .tabItem {
                    Label("Music", systemImage: "music.house") }
            dailyRecommandView()
                .tabItem {
                    Label("Daily for U", systemImage: "music.quarternote.3") }
        }
    }
}

#Preview {
    ContentView()
}
