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
    
    // MARK: - Actions
    func startDestinationWalk() {
        navigationPath.append("DestinationSetting")
    }
    
    func startFreeWalk() {
        navigationPath.append("FreeWalk")
    }
    
    func exploreHoneycombMap() {
        navigationPath.append("HoneycombMap")
    }
}
