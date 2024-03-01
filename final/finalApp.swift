//
//  finalApp.swift
//  final
//
//  Created by Fallere141 on 2/24/24.
//

import SwiftUI

@main
struct finalApp: App {
    
    @State var musicdata = musicData.shared
    @StateObject var globalState = GlobalState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(globalState)
                .task {
                    await initializeData()
                }
        }
    }
    
    func initializeData() async {
        await musicData.shared.initialize()
    }
}
