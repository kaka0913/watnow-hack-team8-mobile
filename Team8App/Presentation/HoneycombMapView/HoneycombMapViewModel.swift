import SwiftUI
import Foundation

@Observable
class HoneycombMapViewModel {
    // MARK: - Services
    private let walkService = WalkService.shared
    
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
        Task {
            await loadWalksData()
        }
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
    
    /// 散歩データを再読み込み
    func refreshWalks() {
        Task {
            await loadWalksData()
        }
    }
    
    /// 現在地周辺の散歩データを取得
    func loadWalksAroundCurrentLocation() {
        Task {
            await loadWalksAroundCurrentLocationData()
        }
    }
    
    // MARK: - Private Methods
    
    /// 散歩データをAPIから取得
    /// - Parameter bbox: バウンディングボックス（オプション）
    @MainActor
    private func loadWalksData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            print("🌐 散歩データ取得開始")
            let walksResponse = try await walkService.getWalks()
            
            // WalkデータをStoryRouteに変換
            let convertedRoutes = walksResponse.walks.map { walk in
                walkService.convertToStoryRoute(walk)
            }
            
            self.storyRoutes = convertedRoutes
            print("✅ 散歩データ取得成功: \(storyRoutes.count)件のルート")
            
            // データが空の場合はモックデータを表示
            if storyRoutes.isEmpty {
                print("⚠️ APIからのデータが空のため、モックデータを表示")
                loadMockData()
            }
            
        } catch {
            print("❌ 散歩データ取得エラー: \(error)")
            handleAPIError(error)
            
            // エラー時はモックデータを表示
            loadMockData()
        }
    }
    
    /// 現在地周辺の散歩データをAPIから取得
    @MainActor
    private func loadWalksAroundCurrentLocationData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            print("📍 現在地周辺の散歩データ取得開始")
            let walksResponse = try await walkService.getWalksAroundCurrentLocation()
            
            // WalkデータをStoryRouteに変換
            let convertedRoutes = walksResponse.walks.map { walk in
                walkService.convertToStoryRoute(walk)
            }
            
            self.storyRoutes = convertedRoutes
            print("✅ 現在地周辺散歩データ取得成功: \(storyRoutes.count)件のルート")
            
            // データが空の場合はモックデータを表示
            if storyRoutes.isEmpty {
                print("⚠️ 現在地周辺のデータが空のため、モックデータを表示")
                loadMockData()
            }
            
        } catch {
            print("❌ 現在地周辺散歩データ取得エラー: \(error)")
            handleAPIError(error)
            
            // エラー時はモックデータを表示
            loadMockData()
        }
    }
    
    /// APIエラーを詳細に処理
    /// - Parameter error: エラー
    private func handleAPIError(_ error: Error) {
        if let error = error as? APIError {
            switch error {
            case .decodingError:
                errorMessage = "データの形式が正しくありません。サーバーにお問い合わせください。"
            case .clientError(let statusCode, _):
                errorMessage = "リクエストエラーが発生しました。(エラーコード: \(statusCode))"
            case .serverError(let statusCode, _):
                errorMessage = "サーバーエラーが発生しました。しばらくしてからお試しください。(エラーコード: \(statusCode))"
            default:
                errorMessage = "ネットワークエラーが発生しました。インターネット接続を確認してください。"
            }
        } else {
            errorMessage = "散歩データの取得に失敗しました。もう一度お試しください。"
        }
    }
    
    /// モックデータを読み込み
    private func loadMockData() {
        storyRoutes = [
            StoryRoute(
                id: "mock_1",
                title: "古都の彩をまとう、祈りの庭散歩",
                description: "陽光浴びて京友禅。鮮やかな色彩に心ときめかせ、世界で一つの模様を創出。神泉苑では、静寂に包まれ、水面に映る空を仰ぐ。古都の雅と自然美に癒やされる、心潤う昼下がりの散歩。",
                duration: 29,
                distance: 1.5,
                category: .nature,
                iconColor: .blue,
                highlights: [
                    RouteHighlight(name: "京友禅工房"),
                    RouteHighlight(name: "神泉苑"),
                    RouteHighlight(name: "寺町通り")
                ]
            ),
            StoryRoute(
                id: "mock_2",
                title: "香をまとう、歴史を歩む - 京の昼下がり",
                description: "晴れた日の京都、老舗の香に包まれ、いざ本能寺へ。織田信長の夢の跡を辿り、歴史の息吹を感じる静寂の散歩道。境内を巡り、昼下がりの陽光を浴びながら、心静かに過去と向き合うひとときを。",
                duration: 6,
                distance: 0.8,
                category: .gourmet,
                iconColor: .green,
                highlights: [
                    RouteHighlight(name: "京都鳩居堂本店"),
                    RouteHighlight(name: "本能寺"),
                    RouteHighlight(name: "寺町通商店街")
                ]
            ),
            StoryRoute(
                id: "mock_3",
                title: "寺町通り、香と歴史を辿る陽だまり散歩",
                description: "晴れた昼下がり、本能寺で織田信長の足跡を偲び、京都鳩居堂本店で心落ち着く香に包まれる。寺町通りを抜け、ギア専用劇場へ。芸術に触れる非日常が、心に新しい風を運び込む、発見に満ちた散歩道。",
                duration: 9,
                distance: 1.2,
                category: .art,
                iconColor: .pink,
                highlights: [
                    RouteHighlight(name: "本能寺"),
                    RouteHighlight(name: "京都鳩居堂本店"),
                    RouteHighlight(name: "ギア専用劇場")
                ]
            )
        ]
        print("📊 京都モックデータを読み込み: \(storyRoutes.count)件のルート")
    }
}
