//
//  HomeView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/19.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            GeometryReader { geometry in
                ZStack {
                    // 背景色 - クリーム色
                    Color(red: 1.0, green: 1.0, blue: 0.90)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 40) {
                        Spacer(minLength: 5)
                        
                        // アプリヘッダー部分
                        AppHeaderView(
                            appTitle: WalkOptionConstants.appTitle,
                            appSubtitle: WalkOptionConstants.appSubtitle
                        )
                        
                        // 散歩オプション部分
                        WalkOptionsSection(viewModel: viewModel)
                            .padding(.horizontal, 24)
                        
                        Spacer().frame(minHeight: 40)
                    }
                }
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "DestinationWalk":
                    DestinationWalkView()
                case "FreeWalk":
                    FreeWalkView()
                case "HoneycombMap":
                    HoneycombMapView()
                default:
                    EmptyView()
                }
            }
            .navigationBarHidden(true) // ホーム画面ではナビゲーションバーを非表示
        }
    }
}

#Preview {
    HomeView()
}
