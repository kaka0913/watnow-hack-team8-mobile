import Foundation
import SwiftUI

@Observable
class DestinationSettingViewModel {
    // MARK: - Properties
    var startLocation: String = "現在地から出発"
    var destination: String = ""
    var selectedTheme: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        return !destination.isEmpty && !selectedTheme.isEmpty
    }
    
    var destinationPlaceholder: String {
        return "どこへ向かいますか？"
    }
    
    var themePlaceholder: String {
        return "どんな発見を求めますか？"
    }
    
    // MARK: - Available Themes
    let availableThemes = [
        "自然・公園",
        "歴史・文化",
        "グルメ・カフェ",
        "ショッピング",
        "アート・ギャラリー",
        "静かな場所",
        "賑やかな場所",
        "フォトスポット"
    ]
    
    // MARK: - Methods
    func updateDestination(_ newDestination: String) {
        destination = newDestination
    }
    
    func selectTheme(_ theme: String) {
        selectedTheme = theme
    }
    
    func searchRoute() async {
        guard isFormValid else {
            errorMessage = "目的地とテーマを選択してください"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // TODO: 実際のルート検索APIを実装
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2秒の模擬遅延
            
            print("ルート検索開始")
            print("出発地: \(startLocation)")
            print("目的地: \(destination)")
            print("テーマ: \(selectedTheme)")
            
            // TODO: 検索結果画面への遷移処理を実装
            
        } catch {
            print("ルート検索に失敗しました: \(error)")
            errorMessage = "ルート検索に失敗しました。もう一度お試しください。"
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func resetForm() {
        destination = ""
        selectedTheme = ""
        errorMessage = nil
    }
}
