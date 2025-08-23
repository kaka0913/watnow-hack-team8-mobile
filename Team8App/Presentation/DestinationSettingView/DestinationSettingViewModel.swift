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
            
            // 目的地の座標を取得（ここではダミー座標を使用）
            let destinationLocation = Location(
                latitude: 34.9735, // ちいかわ
                longitude: 135.7582
            )

            // TODO: API呼び出しを一時的にモックに差し替え
            // let response = try await routeService.generateRouteFromCurrentLocation(
            //     destinationLocation: destinationLocation,
            //     theme: apiTheme
            // )
            
            // モックデータを使用
            let mockResponse = createMockRouteProposalResponse(theme: apiTheme)
            
            // 取得した提案を保存
            self.routeProposals = mockResponse.proposals
            
            print("✅ ルート検索成功（モックデータ使用）")
            print("提案数: \(mockResponse.proposals.count)")
            print("hasRouteProposals: \(hasRouteProposals)")
            
            if let firstProposal = mockResponse.proposals.first {
                print("最初の提案: \(firstProposal.title)")
                print("推定時間: \(firstProposal.estimatedDurationMinutes ?? 0)分")
                print("推定距離: \(firstProposal.estimatedDistanceMeters ?? 0)m")
                print("提案ID: \(firstProposal.proposalId ?? "なし")")
            }
//            
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
    
    // MARK: - Mock Data Generation
    
    private func createMockRouteProposalResponse(theme: String) -> RouteProposalResponse {
        let mockProposals = [
            RouteProposal(
                proposalId: "dest_mock_1",
                title: "\(selectedTheme)を楽しむ散歩道",
                estimatedDurationMinutes: 45,
                estimatedDistanceMeters: 2100,
                theme: theme,
                displayHighlights: getThemeHighlights(theme),
                navigationSteps: createMockNavigationSteps(),
                routePolyline: "mock_polyline_dest_1",
                generatedStory: "\(destination)への道のりで、\(selectedTheme)の魅力を存分に味わえる素敵な散歩コースです。"
            ),
            RouteProposal(
                proposalId: "dest_mock_2",
                title: "隠れた名所を巡る\(selectedTheme)ルート",
                estimatedDurationMinutes: 60,
                estimatedDistanceMeters: 2800,
                theme: theme,
                displayHighlights: getThemeHighlights(theme),
                navigationSteps: createMockNavigationSteps(),
                routePolyline: "mock_polyline_dest_2",
                generatedStory: "地元の人だけが知る隠れた\(selectedTheme)スポットを発見できる、特別な散歩体験をお楽しみください。"
            )
        ]
        
        return RouteProposalResponse(proposals: mockProposals)
    }
    
    private func getThemeHighlights(_ theme: String) -> [String] {
        switch theme {
        case "nature":
            return ["季節の花壇", "野鳥観察スポット", "緑陰の休憩所"]
        case "gourmet":
            return ["老舗カフェ", "地元グルメ", "手作りスイーツ店"]
        case "art":
            return ["ストリートアート", "小さなギャラリー", "アーティスト工房"]
        default:
            return ["魅力的なスポット1", "魅力的なスポット2", "魅力的なスポット3"]
        }
    }
    
    private func createMockNavigationSteps() -> [NavigationStep] {
        return [
            NavigationStep(
                type: .navigation,
                description: "出発地点から歩き始めます",
                distanceToNextMeters: 200,
                poiId: nil,
                name: nil,
                latitude: nil,
                longitude: nil
            ),
            NavigationStep(
                type: .poi,
                description: "最初の見どころに到着",
                distanceToNextMeters: 300,
                poiId: "mock_poi_1",
                name: "魅力的なスポット",
                latitude: 35.6762,
                longitude: 139.7649
            )
        ]
    }
}
