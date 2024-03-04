//
//  SplashScreenView.swift
//  final
//
//  Created by Yun Liu on 3/3/24.
//

import SwiftUI

struct SplashView: View {
    @State private var startAnimation = false
    
    var body: some View {
        ZStack {
            Color("LaunchColor")
                .edgesIgnoringSafeArea(.all)
            
            Image("Launch")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .scaleEffect(startAnimation ? 3 : 1)
                .opacity(startAnimation ? 0 : 1)
                .animation(.easeIn(duration: 1.5), value: startAnimation)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                startAnimation = true
            }
        }
    }
}


