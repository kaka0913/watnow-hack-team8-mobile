import Foundation

protocol StoryRouteRepositoryProtocol {
    func fetchStoryRoutes() async throws -> [StoryRoute]
    func getStoryRoute(id: String) async throws -> StoryRoute?
}

class StoryRouteRepository: StoryRouteRepositoryProtocol {
    static let shared = StoryRouteRepository()
    
    private init() {}
    
    func fetchStoryRoutes() async throws -> [StoryRoute] {
        // モックデータを返す（実際の実装では、APIからデータを取得する）
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒の遅延をシミュレート
        
        return [
            StoryRoute(
                id: "route_001",
                title: "渋谷の隠れた名店巡り",
                description: "地元民だけが知る渋谷の美味しいお店を巡るルートです。",
                duration: 120,
                distance: 2.5,
                category: .gourmet,
                iconColor: .pink,
                highlights: [
                    RouteHighlight(id: "h1", name: "老舗カフェ", iconColor: "brown"),
                    RouteHighlight(id: "h2", name: "隠れ家レストラン", iconColor: "red"),
                    RouteHighlight(id: "h3", name: "地元パン屋", iconColor: "orange")
                ]
            ),
            StoryRoute(
                id: "route_002",
                title: "代々木公園の自然散策",
                description: "四季折々の自然を楽しみながらリラックスできるコースです。",
                duration: 90,
                distance: 3.2,
                category: .nature,
                iconColor: .green,
                highlights: [
                    RouteHighlight(id: "h4", name: "桜並木", iconColor: "pink"),
                    RouteHighlight(id: "h5", name: "池の畔", iconColor: "blue"),
                    RouteHighlight(id: "h6", name: "展望台", iconColor: "green")
                ]
            ),
            StoryRoute(
                id: "route_003",
                title: "表参道アート巡り",
                description: "現代アートと建築美を楽しむクリエイティブなルートです。",
                duration: 150,
                distance: 4.1,
                category: .art,
                iconColor: .purple,
                highlights: [
                    RouteHighlight(id: "h7", name: "現代美術館", iconColor: "purple"),
                    RouteHighlight(id: "h8", name: "建築スポット", iconColor: "gray"),
                    RouteHighlight(id: "h9", name: "ギャラリー", iconColor: "blue")
                ]
            ),
            StoryRoute(
                id: "route_004",
                title: "下北沢カルチャー探訪",
                description: "若者文化とサブカルチャーの聖地を巡るディープなルートです。",
                duration: 180,
                distance: 3.8,
                category: .art,
                iconColor: .blue,
                highlights: [
                    RouteHighlight(id: "h10", name: "ライブハウス", iconColor: "red"),
                    RouteHighlight(id: "h11", name: "古着屋街", iconColor: "yellow"),
                    RouteHighlight(id: "h12", name: "劇場", iconColor: "purple")
                ]
            ),
            StoryRoute(
                id: "route_005",
                title: "恵比寿グルメウォーク",
                description: "高級グルメから庶民的なお店まで、恵比寿の食文化を堪能するルートです。",
                duration: 135,
                distance: 2.8,
                category: .gourmet,
                iconColor: .orange,
                highlights: [
                    RouteHighlight(id: "h13", name: "高級フレンチ", iconColor: "gold"),
                    RouteHighlight(id: "h14", name: "立ち飲み屋", iconColor: "brown"),
                    RouteHighlight(id: "h15", name: "スイーツ店", iconColor: "pink")
                ]
            )
        ]
    }
    
    func getStoryRoute(id: String) async throws -> StoryRoute? {
        let routes = try await fetchStoryRoutes()
        return routes.first { $0.id == id }
    }
}