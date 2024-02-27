//
//  ContentView.swift
//  final
//
//  Created by Fallere141 on 2/24/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Update to DetailView Later
            musicListView()
                .tabItem {
                    Label("music", systemImage: "music.note") }
            musicListView()
                .tabItem {
                    Label("music", systemImage: "music.house") }
            playListView()
                .tabItem {
                    Label("playlist", systemImage: "music.note.list") }
            dailyRecommandView()
                .tabItem {
                    Label("daily recommandation", systemImage: "music.quarternote.3") }
        }
    }
}

#Preview {
    ContentView()
}
