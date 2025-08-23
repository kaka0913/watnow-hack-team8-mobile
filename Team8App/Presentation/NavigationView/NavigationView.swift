//
//  NavigationView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI
import MapKit

// カスタムコーナーラディウス用のExtension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct NavigationView: View {
    let selectedRoute: StoryRoute?
    @State private var viewModel = NavigationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // ボトムシートの状態管理
    @State private var bottomSheetOffset: CGFloat = 0
    @State private var isBottomSheetExpanded: Bool = true
    
    init(selectedRoute: StoryRoute? = nil) {
        self.selectedRoute = selectedRoute
    }
    
    var body: some View {
        GeometryReader { geometry in
            let bottomSheetHeight = geometry.size.height * 0.6
            let collapsedHeight: CGFloat = 120
            let expandedHeight = bottomSheetHeight
            
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
                    
                    // 地図エリア（フルスクリーン）
                    MapContainerView(
                        region: $viewModel.mapRegion,
                        currentLocation: viewModel.currentLocation,
                        route: viewModel.route,
                        isNavigationActive: true
                    )
                    .clipped() // 地図の境界を明確にする
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
                }
                
                // ドラッグ可能なボトムシート
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // ドラッグハンドル領域
                        VStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.4))
                                .frame(width: 40, height: 6)
                                .padding(.top, 12)
                                .padding(.bottom, 8)
                        }
                        .frame(height: 30)
                        .contentShape(Rectangle()) // ドラッグ可能領域を明確に定義
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let translation = value.translation.height
                                    if isBottomSheetExpanded {
                                        // 展開状態：下にドラッグで閉じる
                                        bottomSheetOffset = max(0, translation)
                                    } else {
                                        // 折りたたみ状態：上にドラッグで開く
                                        bottomSheetOffset = min(0, translation)
                                    }
                                }
                                .onEnded { value in
                                    let translation = value.translation.height
                                    let velocity = value.velocity.height
                                    
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        if isBottomSheetExpanded {
                                            // 展開状態からの判定
                                            if translation > 100 || velocity > 500 {
                                                // 閉じる
                                                isBottomSheetExpanded = false
                                                bottomSheetOffset = 0
                                            } else {
                                                // 元に戻す
                                                bottomSheetOffset = 0
                                            }
                                        } else {
                                            // 折りたたみ状態からの判定
                                            if translation < -50 || velocity < -500 {
                                                // 開く
                                                isBottomSheetExpanded = true
                                                bottomSheetOffset = 0
                                            } else {
                                                // 元に戻す
                                                bottomSheetOffset = 0
                                            }
                                        }
                                    }
                                }
                        )
                        
                        // ボトムシートコンテンツ
                        VStack(spacing: 16) {
                            // 道のりセクション
                            RouteStepsView(steps: viewModel.routeSteps)
                                .frame(maxHeight: isBottomSheetExpanded ? .infinity : 0)
                                .clipped()
                            
                            // 散歩終了ボタン
                            Button(action: {
                                viewModel.finishWalk()
                            }) {
                                HStack {
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
                    .frame(height: isBottomSheetExpanded ? expandedHeight : collapsedHeight)
                    .background(Color(.systemBackground))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                    .offset(y: bottomSheetOffset)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isBottomSheetExpanded)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if let route = selectedRoute {
                print("🗺 NavigationView表示: \(route.title)")
                // TODO: viewModel.setSelectedRoute(route)
            }
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
