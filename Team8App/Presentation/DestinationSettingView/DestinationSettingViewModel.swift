import Foundation
import SwiftUI
import CoreLocation

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
    var selectedDestinationPlace: PlaceDetails?
    var selectedStartPlace: PlaceDetails?
    
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
            
            // 出発地点の座標を準備
            let startLocationCoordinate: Location?
            if let selectedStart = selectedStartPlace {
                startLocationCoordinate = Location(
                    latitude: selectedStart.coordinate.latitude,
                    longitude: selectedStart.coordinate.longitude
                )
                print("🚀 Google Places APIから取得した出発地座標を使用: (\(selectedStart.coordinate.latitude), \(selectedStart.coordinate.longitude))")
            } else if startLocation != "現在地から出発" {
                // テキストで入力された場合はnilにして現在地を使用
                print("⚠️ 出発地が「現在地から出発」以外ですが、座標情報がないため現在地を使用します")
                startLocationCoordinate = nil
            } else {
                // 「現在地から出発」の場合
                print("📍 現在地から出発します")
                startLocationCoordinate = nil
            }
            
            // 選択された場所の座標を使用、なければデフォルト座標
            let destinationLocation: Location
            if let selectedPlace = selectedDestinationPlace {
                destinationLocation = Location(
                    latitude: selectedPlace.coordinate.latitude,
                    longitude: selectedPlace.coordinate.longitude
                )
                print("🗺️ Google Places APIから取得した目的地座標を使用: (\(selectedPlace.coordinate.latitude), \(selectedPlace.coordinate.longitude))")
            } else {
                // フォールバック: 京都駅付近
                destinationLocation = Location(
                    latitude: 34.9859,
                    longitude: 135.7581
                )
                print("⚠️ デフォルト座標を使用（京都駅付近）")
            }

            let response = try await routeService.generateRouteFromSpecifiedLocation(
                startLocation: startLocationCoordinate,
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
        startLocation = "現在地から出発"
        destination = ""
        selectedTheme = ""
        showThemeSelection = false
        errorMessage = nil
        routeProposals = []
        selectedDestinationPlace = nil
        selectedStartPlace = nil
    }
    
    func updateSelectedPlace(_ place: PlaceDetails?) {
        selectedDestinationPlace = place
        if let place = place {
            destination = place.name
            print("🏠 目的地が選択されました: \(place.name) at (\(place.coordinate.latitude), \(place.coordinate.longitude))")
        }
    }
    
    func updateSelectedStartPlace(_ place: PlaceDetails?) {
        selectedStartPlace = place
        if let place = place {
            startLocation = place.name
            print("🚀 出発地が選択されました: \(place.name) at (\(place.coordinate.latitude), \(place.coordinate.longitude))")
        }
    }
    
    var hasRouteProposals: Bool {
        return !routeProposals.isEmpty
    }
    

}
