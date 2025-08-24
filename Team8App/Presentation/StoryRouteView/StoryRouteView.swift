import SwiftUI

struct StoryRouteView: View {
    @State private var viewModel = StoryRouteViewModel.shared
    @State private var showNavigationView = false
    @State private var selectedRoute: StoryRoute?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                headerView

                if viewModel.isLoading {
                    ProgressView("読み込み中...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage)
                } else if viewModel.routeProposals.isEmpty {
                    emptyStateView
                } else {
                    let displayProposals = viewModel.routeProposals
                    ForEach(displayProposals, id: \.proposalId) { proposal in
                        StoryRouteCard(
                            route: convertToStoryRoute(proposal),
                            onStartRoute: {
                                let route = convertToStoryRoute(proposal)
                                selectedRoute = route

                                // UserDefaultsに保存
                                saveRouteToUserDefaults(route)

                                showNavigationView = true
                                viewModel.startRoute(route)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text("🗺")
                                .font(.caption)
                        )
                    Text("物語のあるルート")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationDestination(isPresented: $showNavigationView) {
            if let route = selectedRoute {
                NavigationView(selectedRoute: route)
            } else {
                EmptyView()
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 12) {
            Text("どのルートを歩きますか？")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.orange)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

        }
        .padding()
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "map")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("ルート提案がありません")
                .font(.headline)
                .foregroundColor(.primary)

            Text("目的地とテーマを選択してルートを検索してください")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 48)
    }

    private func convertToStoryRoute(_ proposal: RouteProposal) -> StoryRoute {
        print("🔄 StoryRoute変換: \(proposal.title)")
        print("  時間: \(proposal.estimatedDurationMinutes?.description ?? "nil")分")
        print("  距離: \(proposal.estimatedDistanceMeters?.description ?? "nil")m")
        print("  ハイライト: \(proposal.displayHighlights?.count ?? 0)個")
        print("  ポリライン: \(proposal.routePolyline != nil ? "あり(\(proposal.routePolyline!.count)文字)" : "なし")")

        let storyRoute = StoryRoute(
            id: proposal.proposalId ?? UUID().uuidString,
            title: proposal.title,
            description: proposal.generatedStory ?? "素晴らしい散歩ルートです",
            duration: proposal.estimatedDurationMinutes ?? 60,
            distance: Double(proposal.estimatedDistanceMeters ?? 2000) / 1000.0, // メートルをキロメートルに変換
            category: mapThemeToCategory(proposal.theme ?? "gourmet"),
            iconColor: .orange,
            highlights: (proposal.displayHighlights ?? []).map {
                RouteHighlight(name: $0, iconColor: "orange")
            }, routePolyline: proposal.routePolyline // ポリラインデータを正しく設定
        )

        print("  → UIに表示: \(storyRoute.duration)分, \(storyRoute.distance)km, \(storyRoute.highlights.count)個ハイライト, ポリライン: \(storyRoute.routePolyline != nil ? "あり" : "なし")")

        return storyRoute
    }

    private func mapThemeToCategory(_ theme: String) -> StoryRoute.RouteCategory {
        switch theme {
        case "nature":
            return .nature
        case "culture", "art":
            return .art
        default:
            return .gourmet
        }
    }

    private func saveRouteToUserDefaults(_ route: StoryRoute) {
        // 対応するRouteProposalを見つける
        guard let proposal = findOriginalProposal(for: route) else {
            print("❌ 元のRouteProposalが見つかりません")
            return
        }

        // UserDefaultsに選択されたルート情報を保存
        let userDefaults = UserDefaults.standard
        userDefaults.set(route.id, forKey: "currentProposalId")
        userDefaults.set(route.title, forKey: "currentRouteTitle")
        userDefaults.set(route.duration, forKey: "currentRouteDuration")
        userDefaults.set(route.distance, forKey: "currentRouteDistance")
        userDefaults.set(route.description, forKey: "currentRouteDescription")

        // 実際のAPIデータから詳細情報を保存
        if let highlights = proposal.displayHighlights {
            let highlightsData = try? JSONEncoder().encode(highlights)
            userDefaults.set(highlightsData, forKey: "currentRouteHighlights")
        }

        if let navigationSteps = proposal.navigationSteps {
            let stepsData = try? JSONEncoder().encode(navigationSteps)
            userDefaults.set(stepsData, forKey: "currentRouteNavigationSteps")
        }

        userDefaults.set(proposal.generatedStory, forKey: "currentRouteStory")
        userDefaults.set(proposal.routePolyline, forKey: "currentRoutePolyline")
        userDefaults.set(proposal.estimatedDurationMinutes, forKey: "currentRouteActualDuration")
        userDefaults.set(proposal.estimatedDistanceMeters, forKey: "currentRouteActualDistance")

        // WalkModeを文字列として保存
        userDefaults.set("destination", forKey: "currentWalkMode")

        // 保存を確実に実行
        userDefaults.synchronize()

        print("📍 StoryRouteViewで実際のAPIデータを保存:")
        print("   - ID: \(route.id)")
        print("   - タイトル: \(route.title)")
        print("   - 時間: \(proposal.estimatedDurationMinutes ?? 0)分（実際のAPI値）")
        print("   - 距離: \(proposal.estimatedDistanceMeters ?? 0)m（実際のAPI値）")
        print("   - ハイライト: \(proposal.displayHighlights?.count ?? 0)個")
        print("   - ナビゲーションステップ: \(proposal.navigationSteps?.count ?? 0)個")
        print("   - ストーリー: \(proposal.generatedStory != nil ? "あり" : "なし")")
        print("💾 実際のAPIデータをUserDefaultsに保存完了")
    }

    private func findOriginalProposal(for route: StoryRoute) -> RouteProposal? {
        return viewModel.routeProposals.first { proposal in
            proposal.proposalId == route.id
        }
    }

}
