import SwiftUI
import Foundation

@Observable
class HoneycombMapViewModel {
    // MARK: - State Properties
    var isMapView: Bool = true
    var selectedRoute: StoryRoute?
    var isShowingRouteDetail: Bool = false
    var storyRoutes: [StoryRoute] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    var displayMode: DisplayMode {
        return isMapView ? .map : .list
    }
    
    // MARK: - Enums
    enum DisplayMode {
        case map
        case list
    }
    
    // MARK: - Initialization
    init() {
        loadMockData()
    }
    
    // MARK: - Public Methods
    func toggleDisplayMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isMapView.toggle()
        }
        print("📱 表示モード切り替え: \(isMapView ? "マップ" : "リスト")")
    }
    
    func selectRoute(_ route: StoryRoute) {
        selectedRoute = route
        isShowingRouteDetail = true
        print("🗺️ ルート選択: \(route.title)")
    }
    
    func clearSelection() {
        selectedRoute = nil
        isShowingRouteDetail = false
        print("🔄 ルート選択をクリア")
    }
    
    // MARK: - Private Methods
    private func loadMockData() {
        // モックデータを設定
        storyRoutes = [
            StoryRoute(
                id: "1",
                title: "雨上がりの虹色散歩道",
                description: "雨上がりの街に現れた小さな虹を追いかけて、思いがけない出会いと発見に満ちた散歩になりました。",
                duration: 38,
                distance: 2.1,
                category: .nature,
                iconColor: .blue,
                highlights: [
                    RouteHighlight(name: "青山公園"),
                    RouteHighlight(name: "表参道カフェ"),
                    RouteHighlight(name: "虹の橋展望台")
                ]
            ),
            StoryRoute(
                id: "2",
                title: "猫たちが案内する、隠れ家カフェ巡り",
                description: "街角の猫たちに導かれるように、知る人ぞ知る素敵なカフェを3軒も発見。猫好きにはたまらない散歩でした。",
                duration: 52,
                distance: 1.8,
                category: .gourmet,
                iconColor: .green,
                highlights: [
                    RouteHighlight(name: "ねこカフェ みやお"),
                    RouteHighlight(name: "隠れ家ベーカリー"),
                    RouteHighlight(name: "アートギャラリー猫")
                ]
            ),
            StoryRoute(
                id: "3",
                title: "桜並木とアートの小径",
                description: "満開の桜とストリートアートが織りなす美しい街並みを歩きながら、春の訪れを感じる散歩。",
                duration: 45,
                distance: 2.5,
                category: .art,
                iconColor: .pink,
                highlights: [
                    RouteHighlight(name: "桜坂通り"),
                    RouteHighlight(name: "アート壁画"),
                    RouteHighlight(name: "季節のカフェ")
                ]
            ),
            StoryRoute(
                id: "4",
                title: "夕焼け空と海辺の散策",
                description: "夕方の海辺を歩きながら、美しい夕焼けと波の音に癒される特別な時間。",
                duration: 35,
                distance: 1.9,
                category: .nature,
                iconColor: .orange,
                highlights: [
                    RouteHighlight(name: "海浜公園"),
                    RouteHighlight(name: "夕焼けスポット"),
                    RouteHighlight(name: "海辺カフェ")
                ]
            )
        ]
        print("📊 モックデータを読み込み: \(storyRoutes.count)件のルート")
    }
}
