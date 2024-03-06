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
    
    init() {
        
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            UserDefaults.standard.set(Date(), forKey: "Initial Launch")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
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
                    SplashView{
                        isLoading = false
                    }
                        .transition(.opacity)
                }
            }
        }
    }
    
    func initializeData() async {
        await musicData.shared.initialize()
    }
}

