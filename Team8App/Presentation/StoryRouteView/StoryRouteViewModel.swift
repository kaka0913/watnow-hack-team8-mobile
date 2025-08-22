import Foundation

@Observable
class StoryRouteViewModel {
    var storyRoutes: [StoryRoute] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    // private let storyRouteRepository = StoryRouteRepository.shared
    
    init() {
        Task {
            await fetchStoryRoutes()
        }
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
}
