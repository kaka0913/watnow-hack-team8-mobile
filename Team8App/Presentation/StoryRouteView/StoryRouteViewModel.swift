import Foundation

@Observable
class StoryRouteViewModel {
    static let shared = StoryRouteViewModel()
    
    var storyRoutes: [StoryRoute] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var routeProposals: [RouteProposal] = []
    
    // private let storyRouteRepository = StoryRouteRepository.shared
    
    private init() {
        Task {
            await fetchStoryRoutes()
        }
        // 実際のAPIデータのみを使用するため、初期状態は空配列
        routeProposals = []
    }
    
    @MainActor
    func fetchStoryRoutes() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
//            let routes = try await storyRouteRepository.fetchStoryRoutes()
//            self.storyRoutes = routes
        } catch {
            print("ストーリールートの取得に失敗しました: \(error)")
            self.errorMessage = "ルートの読み込みに失敗しました。もう一度お試しください。"
        }
    }
    
    func startRoute(_ route: StoryRoute) {
        print("ルートを開始: \(route.title)")
        
        // 対応するRouteProposalを探してポリライン情報も保存
        if let matchingProposal = routeProposals.first(where: { $0.proposalId == route.id }) {
            saveRouteProposalData(route, proposal: matchingProposal)
        }
        
        // ここでナビゲーション開始の処理を実装
    }
    
    private func saveRouteProposalData(_ route: StoryRoute, proposal: RouteProposal) {
        let userDefaults = UserDefaults.standard
        
        // 基本情報を保存
        userDefaults.set(route.id, forKey: "currentProposalId")
        userDefaults.set(route.title, forKey: "currentRouteTitle")
        userDefaults.set(route.duration, forKey: "currentRouteDuration")
        userDefaults.set(route.distance, forKey: "currentRouteDistance")
        userDefaults.set(route.description, forKey: "currentRouteDescription")
        
        // WalkModeを文字列として保存
        userDefaults.set("destination", forKey: "currentWalkMode")
        
        // 目的地座標を保存（DestinationSettingViewModelと同じ座標）
        userDefaults.set(34.9735, forKey: "currentDestinationLatitude")
        userDefaults.set(135.7582, forKey: "currentDestinationLongitude")
        
        // 実際のAPIデータを保存
        if let duration = proposal.estimatedDurationMinutes {
            userDefaults.set(duration, forKey: "currentRouteActualDuration")
        }
        if let distance = proposal.estimatedDistanceMeters {
            userDefaults.set(distance, forKey: "currentRouteActualDistance")
        }
        if let story = proposal.generatedStory {
            userDefaults.set(story, forKey: "currentRouteStory")
        }
        if let polyline = proposal.routePolyline {
            userDefaults.set(polyline, forKey: "currentRoutePolyline")
        }
        
        // ハイライトを保存
        if let highlights = proposal.displayHighlights {
            let highlightsData = try? JSONEncoder().encode(highlights)
            userDefaults.set(highlightsData, forKey: "currentRouteHighlights")
        }
        
        // ナビゲーションステップを保存
        if let navigationSteps = proposal.navigationSteps {
            let stepsData = try? JSONEncoder().encode(navigationSteps)
            userDefaults.set(stepsData, forKey: "currentRouteNavigationSteps")
        }
        
        userDefaults.synchronize()
        
        print("💾 RouteProposalデータをUserDefaultsに保存完了:")
        print("   - ProposalID: \(route.id)")
        print("   - タイトル: \(route.title)")
        print("   - 実際の時間: \(proposal.estimatedDurationMinutes ?? 0)分")
        print("   - 実際の距離: \(proposal.estimatedDistanceMeters ?? 0)m")
        print("   - ポリライン: \(proposal.routePolyline != nil ? "保存完了" : "なし")")
        print("   - ストーリー: \(proposal.generatedStory != nil ? "保存完了" : "なし")")
        print("   - ナビステップ: \(proposal.navigationSteps?.count ?? 0)個")
    }
    
    // 実際のAPIデータを設定
    func setRouteProposals(_ proposals: [RouteProposal]) {
        self.routeProposals = proposals
    }
    
    // RouteProposalからStoryRouteに変換したデータを取得
    func getConvertedStoryRoutes() -> [StoryRoute] {
        return routeProposals.map { proposal in
            StoryRoute(
                id: proposal.proposalId ?? UUID().uuidString,
                title: proposal.title,
                description: proposal.generatedStory ?? "素晴らしい散歩ルートです",
                duration: proposal.estimatedDurationMinutes ?? 60,
                distance: Double(proposal.estimatedDistanceMeters ?? 2000) / 1000.0,
                category: mapThemeToCategory(proposal.theme ?? "gourmet"),
                iconColor: .orange,
                highlights: (proposal.displayHighlights ?? []).map {
                    RouteHighlight(name: $0, iconColor: "orange")
                },
                routePolyline: proposal.routePolyline // ポリラインデータを正しく設定
            )
        }
    }
    
    // テーマからカテゴリーへのマッピング
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
    

}
