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
        // TODO: 実際に叩けるように修正
        routeProposals = getMockRouteProposals()
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
        // ここでナビゲーション開始の処理を実装
    }
    
    // 実際のAPIデータを設定
    func setRouteProposals(_ proposals: [RouteProposal]) {
        self.routeProposals = proposals
    }
    
    // クソみたいな仮の処理 - モックデータ生成
    func getMockRouteProposals() -> [RouteProposal] {
        return [
            RouteProposal(
                proposalId: "mock_1",
                title: "黄昏の蜜蜂が紡ぐ、古き良き商店街の物語",
                estimatedDurationMinutes: 45,
                estimatedDistanceMeters: 2100,
                theme: "gourmet",
                displayHighlights: ["老舗和菓子店", "昭和レトロ喫茶", "手作り雑貨店"],
                navigationSteps: [],
                routePolyline: "mock_polyline_1",
                generatedStory: "昭和の香りが漂う商店街を抜け、隠れた名店で地元の人々との出会いを楽しむ散歩です。蜜蜂のように街角を巡りながら、甘い思い出を集めていきましょう。"
            ),
            RouteProposal(
                proposalId: "mock_2", 
                title: "緑陰に響く鳥のさえずり、都市のオアシス散歩",
                estimatedDurationMinutes: 60,
                estimatedDistanceMeters: 2800,
                theme: "nature",
                displayHighlights: ["都市公園", "野鳥観察スポット", "季節の花壇"],
                navigationSteps: [],
                routePolyline: "mock_polyline_2",
                generatedStory: "都市の喧騒を忘れ、緑豊かな公園で自然の息づかいを感じる散歩コース。四季折々の花々と野鳥たちが、あなたの心を癒してくれるでしょう。"
            ),
            RouteProposal(
                proposalId: "mock_3",
                title: "アートが息づく街角、創造性との出会い",
                estimatedDurationMinutes: 50,
                estimatedDistanceMeters: 2400,
                theme: "art",
                displayHighlights: ["ストリートアート", "小さなギャラリー", "アーティストカフェ"],
                navigationSteps: [],
                routePolyline: "mock_polyline_3", 
                generatedStory: "街角に隠れたアート作品を発見しながら、クリエイティブな刺激に満ちた散歩を楽しみます。アーティストたちの情熱が込められた作品との出会いが待っています。"
            )
        ]
    }
}
