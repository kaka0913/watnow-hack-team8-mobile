//
//  WalkSummaryView.swift
//  Team8App
//
//  Created by JUNNY on 2025/08/04.
//

// WalkSummaryView.swift
import SwiftUI

struct WalkSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = WalkSummaryViewModel()
    @State private var shouldDismissToHome = false
    
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 1.0,blue: 0.90)
                .ignoresSafeArea()
            
            
            
            
            VStack(alignment: .leading, spacing: 10) {
                VStack {
                    // Header section
                    HeaderView(onDismiss: { 
                        dismiss()
                    })
                    
                    // Walk Summary Card
                    WalkSummaryCard(viewModel: viewModel)
                    
                    // Today's Discovery Card
                    DiscoveryCard(visitedSpots: viewModel.visitedSpots)
                    
                    // ハニカムマップ投稿セクション
                    PostSelectionCard(
                        viewModel: viewModel,
                        onNavigateToHome: {
                            print("🏠 HomeViewへの遷移が要求されました")
                            
                            // 保存されたルート情報をクリア
                            let userDefaults = UserDefaults.standard
                            userDefaults.removeObject(forKey: "currentProposalId")
                            userDefaults.removeObject(forKey: "currentRouteTitle")
                            userDefaults.removeObject(forKey: "currentRouteDuration")
                            userDefaults.removeObject(forKey: "currentRouteDistance")
                            userDefaults.removeObject(forKey: "currentRouteDescription")
                            userDefaults.removeObject(forKey: "currentWalkMode")
                            userDefaults.removeObject(forKey: "currentRouteHighlights")
                            userDefaults.removeObject(forKey: "currentRouteNavigationSteps")
                            userDefaults.removeObject(forKey: "currentRouteStory")
                            userDefaults.removeObject(forKey: "currentRoutePolyline")
                            userDefaults.removeObject(forKey: "currentRouteActualDuration")
                            userDefaults.removeObject(forKey: "currentRouteActualDistance")
                            userDefaults.removeObject(forKey: "currentDestinationLatitude")
                            userDefaults.removeObject(forKey: "currentDestinationLongitude")
                            userDefaults.synchronize()
                            print("🗑 ルート情報をクリアしました")
                            
                            shouldDismissToHome = true
                            print("🏠 shouldDismissToHome = \(shouldDismissToHome)")
                        }
                    )
                    
                    Spacer()

                }
                .padding(.horizontal, 16)
            }
            
        }
        .navigationBarHidden(true)
        .onChange(of: shouldDismissToHome) { oldValue, newValue in
            print("🏠 shouldDismissToHome変更: \(oldValue) -> \(newValue)")
            if newValue {
                // 全てのナビゲーションスタックを解除してHomeViewに戻る
                print("🏠 ナビゲーションスタックを解除してHomeViewに戻ります")
                
                // 複数のdismissを実行してルートまで戻る
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dismiss() // WalkSummaryViewを閉じる
                    
                    // さらにNavigationViewも閉じる必要がある場合
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.onDismiss = { dismiss() }
        }
    }
}
