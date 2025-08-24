import SwiftUI
import Foundation

@Observable
class HoneycombMapViewModel {
    // MARK: - Services
    private let walkService = WalkService.shared
    private let storyRouteViewModel = StoryRouteViewModel.shared
    
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
        // RouteProposalデータがある場合はそれを優先、なければWalkデータを取得
        Task {
            await loadRouteData()
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
            await loadRouteData()
        }
    }
    
    /// 現在地周辺の散歩データを取得
    func loadWalksAroundCurrentLocation() {
        Task {
            await loadWalksAroundCurrentLocationData()
        }
    }
    
    // MARK: - Private Methods
    
    /// ルートデータを取得（RouteProposal優先、なければWalkデータ）
    @MainActor
    private func loadRouteData() async {
        // まずRouteProposalデータを確認
        let routeProposalRoutes = storyRouteViewModel.getConvertedStoryRoutes()
        
        if !routeProposalRoutes.isEmpty {
            print("🗺️ RouteProposalデータを使用: \(routeProposalRoutes.count)件")
            self.storyRoutes = routeProposalRoutes
            return
        }
        
        // RouteProposalデータがない場合はWalkデータを取得
        print("🗺️ RouteProposalデータがないため、Walkデータを取得")
        await loadWalksData()
    }
    
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
            }
            
        } catch {
            print("❌ 散歩データ取得エラー: \(error)")
            handleAPIError(error)
            

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
            }
            
        } catch {
            print("❌ 現在地周辺散歩データ取得エラー: \(error)")
            handleAPIError(error)
            

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
    
}
