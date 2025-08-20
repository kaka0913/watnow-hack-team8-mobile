//
//  HomeViewModel.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/19.
//

import SwiftUI

@Observable
class HomeViewModel {
    // MARK: - Properties
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Navigation Properties
    var navigationPath = NavigationPath()
    
    // MARK: - Walk Option Properties (WalkOptionCard用)
    var appTitle: String {
        return "BeFree"
    }
    
    var appSubtitle: String {
        return "蜜を集めるように、街の魅力を巡る散歩へ"
    }
    
    var destinationWalkTitle: String {
        return "目的地を決めて出発"
    }
    
    var destinationWalkSubtitle: String {
        return "寄り道しながらのんびりと散歩しよう"
    }
    
    var noDestinationWalkTitle: String {
        return "目的地なしで出発"
    }
    
    var noDestinationWalkSubtitle: String {
        return "時間だけ決めて、気ままに散歩を"
    }
    
    var exploreMapTitle: String {
        return "ハニカムマップを見る"
    }
    
    var exploreMapSubtitle: String {
        return "他の散歩者を追体験しよう"
    }
    
    // MARK: - Actions
    func startDestinationWalk() {
        // ナビゲーション画面に遷移
        navigationPath.append("NavigationView")
    }
    
    func startFreeWalk() {
        navigationPath.append("FreeWalk")
    }
    
    func exploreHoneycombMap() {
        // ハニカムマップ探索画面に遷移するロジックを実装予定
        print("ハニカムマップ探索画面に遷移")
    }
}
