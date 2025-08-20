//
//  NavigationView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI
import MapKit

struct NavigationView: View {
    @State private var viewModel = NavigationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景色 - クリーム色
                Color(red: 1.0, green: 1.0, blue: 0.90)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // ナビゲーションヘッダー
                    NavigationHeaderView(
                        remainingTime: viewModel.remainingTime,
                        remainingDistance: viewModel.remainingDistance,
                        onDismiss: { dismiss() }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // 地図エリア
                    MapContainerView(
                        region: $viewModel.mapRegion,
                        currentLocation: viewModel.currentLocation,
                        route: viewModel.route,
                        isNavigationActive: true
                    )
                    .frame(height: geometry.size.height * 0.45)
                    .overlay(
                        // 現在地情報カード
                        VStack {
                            Spacer()
                            CurrentLocationCard(
                                locationName: viewModel.currentLocationName,
                                storyText: viewModel.currentStoryText
                            )
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                    )
                    .overlay(
                        // ハニービーアイコン
                        VStack {
                            HStack {
                                Spacer()
                                HoneyBeeIcon()
                                    .padding(.trailing, 16)
                                    .padding(.top, 16)
                            }
                            Spacer()
                        }
                    )
                    
                    // 道のりセクション
                    RouteStepsView(steps: viewModel.routeSteps)
                    
                    // 散歩終了ボタン
                    Button(action: {
                        viewModel.finishWalk()
                    }) {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("散歩を終了する")
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.8))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.startNavigation()
            }
        }
        .sheet(isPresented: $viewModel.showWalkSummary) {
            WalkSummaryView()
        }
    }
}

#Preview {
    NavigationView()
}