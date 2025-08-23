import Foundation
import SwiftUI

@Observable
class DestinationSettingViewModel {
    private let routeService = RouteService.shared
    var startLocation: String = "現在地から出発"
    var destination: String = ""
    var selectedTheme: String = ""
    var showThemeSelection: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    var routeProposals: [RouteProposal] = []
    
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
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            print("ルート検索開始")
            print("出発地: \(startLocation)")
            print("目的地: \(destination)")
            print("テーマ: \(selectedTheme)")
            
            // UI用のテーマをAPI用に変換
            let apiTheme = routeService.mapUIThemeToAPITheme(selectedTheme)
            
            // TODO:目的地の座標を取得（ここではダミー座標を使用）
            let destinationLocation = Location(
                latitude: 34.9735, // ちいかわ
                longitude: 135.7582
            )

            let response = try await routeService.generateRouteFromCurrentLocation(
                destinationLocation: destinationLocation,
                theme: apiTheme
            )

            self.routeProposals = response.proposals
            
            print("📱 実際のAPI呼び出し成功:")
            print("   - 提案数: \(response.proposals.count)")
            for (index, proposal) in response.proposals.enumerated() {
                print("   [提案\(index + 1)]")
                print("     - タイトル: \(proposal.title)")
                print("     - ProposalID: \(proposal.proposalId ?? "なし")")
                print("     - 時間: \(proposal.estimatedDurationMinutes ?? 0)分")
                print("     - 距離: \(proposal.estimatedDistanceMeters ?? 0)m")
                print("     - テーマ: \(proposal.theme ?? "なし")")
                print("     - ハイライト数: \(proposal.displayHighlights?.count ?? 0)")
                if let highlights = proposal.displayHighlights {
                    print("     - ハイライト: \(highlights)")
                }
                print("     - ストーリー: \(proposal.generatedStory?.prefix(50) ?? "なし")...")
            }
            
            print("✅ ルート検索成功（実際のAPI使用）")
            print("hasRouteProposals: \(hasRouteProposals)")
        } catch {
            print("❌ ルート検索に失敗しました: \(error)")
            
            if let apiError = error as? APIError {
                switch apiError {
                case .clientError(let statusCode, _):
                    errorMessage = "リクエストに問題があります（\(statusCode)）。入力内容を確認してください。"
                case .serverError(_, _):
                    errorMessage = "サーバーに問題が発生しています。しばらく待ってからお試しください。"
                case .decodingError(_):
                    errorMessage = "データの解析に失敗しました。"
                default:
                    errorMessage = "予期しないエラーが発生しました。"
                }
            } else {
                errorMessage = "ルート検索に失敗しました。もう一度お試しください。"
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func resetForm() {
        destination = ""
        selectedTheme = ""
        showThemeSelection = false
        errorMessage = nil
        routeProposals = []
    }
    
    var hasRouteProposals: Bool {
        return !routeProposals.isEmpty
    }
    

}
