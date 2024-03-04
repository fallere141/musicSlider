//
//  finalApp.swift
//  final
//
//  Created by Fallere141 on 2/24/24.
//

import SwiftUI

@main
struct finalApp: App {
    @StateObject var globalState = GlobalState()
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(globalState)
                    .task {
                        await initializeData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isLoading = false
                        }
                    }
                
                if isLoading {
                    SplashView()
                        .transition(.opacity) 
                }
            }
        }
    }
    
    func initializeData() async {
        await musicData.shared.initialize()
    }
}

