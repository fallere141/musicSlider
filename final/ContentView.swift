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

    @State private var showRateAppAlert = false

    var body: some View {
        TabView(selection: $globalState.selectedTab) {
            DetailView()
                .tabItem {
                    Label("Slider", systemImage: "music.note")
                }.tag(0)
                .environmentObject(globalState)
            
            playListView(globalState: globalState)
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
        }
        .environmentObject(globalState)
        .onAppear {
            globalState.appLaunchCount += 1
            
            if globalState.appLaunchCount == 3 {
                showRateAppAlert = true
            }
        }
        .alert(isPresented: $showRateAppAlert) {
            Alert(
                title: Text("Rate Us"),
                message: Text("If you enjoy using the app, please take a moment to rate it in the App Store."),
                primaryButton: .default(Text("Rate")) {
                    print("User chose to rate the app")
                },
                secondaryButton: .cancel()
            )
        }
    }
}
