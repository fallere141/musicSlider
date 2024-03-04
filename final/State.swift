//
//  State.swift
//  final
//
//  Created by Yun Liu on 2/28/24.
//

import Foundation

/// `GlobalState` is a class designed to manage and share the global state across the SwiftUI application.
class GlobalState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var navigateToDetailView: Bool = false
    @Published var detailViewSongIndex: Int = 0
}
