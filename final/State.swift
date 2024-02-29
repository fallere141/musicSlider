//
//  State.swift
//  final
//
//  Created by Yun Liu on 2/28/24.
//

import Foundation

class GlobalState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var navigateToDetailView: Bool = false
    @Published var detailViewSongIndex: Int = 0
}
