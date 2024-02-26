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
            musicListView()
                .tabItem {
                    Label("music", systemImage: "play.house") }
            playListView()
                .tabItem {
                    Label("playlist", systemImage: "text.line.first.and.arrowtriangle.forward") }
            dailyRecommandView()
                .tabItem {
                    Label("daily recommandation", systemImage: "text.line.first.and.arrowtriangle.forward") }
        }
    }
}

#Preview {
    ContentView()
}
