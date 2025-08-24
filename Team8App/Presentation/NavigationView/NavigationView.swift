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
                        routeTitle: viewModel.routeTitle,
                        onDismiss: { dismiss() }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // 地図エリア（フルスクリーン）
                    MapContainerView(
                        region: $viewModel.mapRegion,
                        routeCoordinates: $viewModel.routeCoordinates,
                        annotations: $viewModel.annotations,
                        onLocationUpdate: { coordinate in
                            viewModel.currentLocation = coordinate
                        }
                    )
                    .clipped() // 地図の境界を明確にする
                    .overlay(
                        // ハニービーアイコン
                        VStack {
                            HStack {
                                Spacer()
                                HoneyBeeIcon(onTap: {
                                    viewModel.showRouteDeviationDialog = true
                                })
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
                            RouteStepsView(steps: viewModel.routeSteps, storyText: viewModel.currentStoryText)
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
            
            // ルート逸脱ダイアログオーバーレイ
            if viewModel.showRouteDeviationDialog {
                RouteDeviationDialog(
                    isPresented: $viewModel.showRouteDeviationDialog,
                    onRecalculateRoute: {
                        Task {
                            await viewModel.recalculateRoute()
                            await MainActor.run {
                                viewModel.dismissRouteDeviationDialog()
                            }
                        }
                    }
                )
                .onDisappear {
                    viewModel.dismissRouteDeviationDialog()
                }
            }
            
            if viewModel.isLoading {
                LoadingOverlay()
            }
            
            if viewModel.showRouteUpdateCompleteDialog {
                RouteUpdateCompleteDialog(
                    isPresented: $viewModel.showRouteUpdateCompleteDialog
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if let route = selectedRoute {
                print("🗺 NavigationView表示: \(route.title)")
                viewModel.setSelectedRoute(route)
            }
            Task {
                await viewModel.startNavigation()
            }
        }
        .navigationDestination(isPresented: $viewModel.showWalkSummary) {
            WalkSummaryView()
        }
    }
}

// MARK: - LoadingOverlay
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("新しいルートを計算中...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .cornerRadius(16)
        }
        .animation(.easeInOut(duration: 0.3), value: true)
    }
}

// MARK: - RouteUpdateCompleteDialog
struct RouteUpdateCompleteDialog: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 24) {
                // アイコンとタイトル
                VStack(spacing: 16) {
                    Circle()
                        .fill(.green)
                        .frame(width: 60, height: 60)
                        .overlay {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                    
                    Text("ルート更新完了！")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                // メッセージ
                Text("新しいルートに更新されました。\n引き続き散歩をお楽しみください。")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                // 確認ボタン
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented = false
                    }
                }) {
                    Text("続ける")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.blue)
                        .cornerRadius(12)
                }
            }
            .padding(32)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 32)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
    }
}
