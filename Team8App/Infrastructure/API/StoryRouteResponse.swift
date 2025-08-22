import Foundation

class StoryRouteRepository: StoryRouteRepositoryProtocol {
    static let shared = StoryRouteRepository()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    func fetchStoryRoutes() async throws -> [StoryRoute] {
        // For demonstration, returning mock data instead of API call
        // In production, this would be: let response: StoryRouteResponse = try await apiClient.request(StoryRouteRequest())
        return createMockData()
    }
    
    private func createMockData() -> [StoryRoute] {
        return [
            StoryRoute(
                id: "1",
                title: "黄昏の蜜蜂が舞う、古き良き商店街の物語",
                description: "昭和の香り漂う商店街を歩け、隠れた名店で地元の人々との出会いを楽しむ",
                duration: 45,
                distance: 2.1,
                category: .gourmet,
                iconColor: .pink,
                highlights: [
                    RouteHighlight(name: "老舗和菓子店"),
                    RouteHighlight(name: "昭和レトロ喫茶"),
                    RouteHighlight(name: "手作り雑貨店")
                ]
            ),
            StoryRoute(
                id: "2",
                title: "桜並木に導かれし、静寂なる午後の詩",
                description: "季節の花々に彩られた公園を巡り、ベンチで読書タイムも楽しめる",
                duration: 52,
                distance: 2.8,
                category: .nature,
                iconColor: .green,
                highlights: [
                    RouteHighlight(name: "桜並木遊歩道"),
                    RouteHighlight(name: "池のほとりベンチ"),
                    RouteHighlight(name: "野鳥観察スポット")
                ]
            ),
            StoryRoute(
                id: "3",
                title: "路地裏に眠る宝物、アーティストたちの秘密基地",
                description: "小さなギャラリーアトリエが点在する、クリエイティブな街角を探索",
                duration: 38,
                distance: 1.9,
                category: .art,
                iconColor: .purple,
                highlights: [
                    RouteHighlight(name: "隠れギャラリー"),
                    RouteHighlight(name: "アーティスト工房"),
                    RouteHighlight(name: "壁画アート")
                ]
            )
        ]
    }
}
