import SwiftUI
import Foundation

@Observable
class StoryRouteDetailViewModel {
    // MARK: - State Properties
    var route: StoryRoute
    var isStartingNavigation: Bool = false
    
    // MARK: - Initialization
    init(route: StoryRoute) {
        self.route = route
        print("📱 ストーリールート詳細画面を初期化: \(route.title)")
    }
    
    // MARK: - Public Methods
    func startNavigation() {
        isStartingNavigation = true
        // TODO: ナビゲーション開始の処理
        print("🚀 ナビゲーション開始: \(route.title)")
        
        // 実際の処理後にローディング状態を解除
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isStartingNavigation = false
        }
    }
    
    func formatDuration() -> String {
        return "\(route.duration)分"
    }
    
    func formatDistance() -> String {
        return String(format: "%.1fkm", route.distance)
    }
    
    func formatLocation() -> String {
        // 実際のプロジェクトでは、ルートの開始地点情報を使用
        return "渋谷・表参道エリア"
    }
    
    func formatDate() -> String {
        // 実際のプロジェクトでは、作成日時やおすすめ日時を使用
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: Date())
    }
}
