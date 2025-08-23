//
//  RouteService.swift
//  Team8App
//
//  Created by AI Assistant on 2025/01/27.
//

import Foundation

class RouteService {
    static let shared = RouteService()
    private let routeRepository = RouteRepository.shared
    
    private init() {}
    
    func generateRouteProposals(
        startLocation: Location,
        destinationLocation: Location?,
        mode: WalkMode,
        timeMinutes: Int?,
        theme: String,
        weather: String,
        timeOfDay: String
    ) async throws -> RouteProposalResponse {
        
        // 目的地モードの場合はdurationを120分に設定（curlと同じ）
        let durationMinutes = mode == .destination ? 120 : timeMinutes
        
        let request = RouteProposalRequest(
            startLocation: startLocation,
            destination: destinationLocation,
            mode: mode,
            durationMinutes: durationMinutes,
            theme: theme
        )
        
        return try await routeRepository.generateRouteProposals(request: request)
    }
    
    func recalculateRoute(
        proposalId: String,
        currentLocation: Location,
        destinationLocation: Location?,
        mode: WalkMode,
        visitedPois: [VisitedPoi],
        weather: String,
        timeOfDay: String
    ) async throws -> RouteRecalculateResponse {
        
        let visitedPoisRequest = VisitedPois(previousPois: visitedPois)
        
        let request = RouteRecalculateRequest(
            proposalId: proposalId,
            currentLocation: currentLocation,
            destination: destinationLocation,
            mode: mode,
            visitedPois: visitedPoisRequest
        )
        
        return try await routeRepository.recalculateRoute(request: request)
    }
}

// MARK: - Convenience Methods

extension RouteService {
    
    /// 目的地指定ルートの提案を生成（簡単メソッド）
    func generateDestinationRoute(
        startLocation: Location,
        destinationLocation: Location,
        theme: String
    ) async throws -> RouteProposalResponse {
        
        return try await generateRouteProposals(
            startLocation: startLocation,
            destinationLocation: destinationLocation,
            mode: .destination,
            timeMinutes: 120, // curlと同じ値を設定
            theme: theme,
            weather: getCurrentWeather(),
            timeOfDay: getCurrentTimeOfDay()
        )
    }
    
    /// 時間ベースルートの提案を生成（簡単メソッド）
    func generateTimedRoute(
        startLocation: Location,
        timeMinutes: Int,
        theme: String
    ) async throws -> RouteProposalResponse {
        
        return try await generateRouteProposals(
            startLocation: startLocation,
            destinationLocation: nil,
            mode: .timeBased,
            timeMinutes: timeMinutes,
            theme: theme,
            weather: getCurrentWeather(),
            timeOfDay: getCurrentTimeOfDay()
        )
    }
    
    /// 現在地からの簡単なルート提案
    func generateRouteFromCurrentLocation(
        destinationLocation: Location?,
        theme: String,
        timeMinutes: Int? = nil
    ) async throws -> RouteProposalResponse {
        
        // TODO: 実際の現在地取得を実装（ここではダミー座標）
        let currentLocation = Location(latitude: 35.0116, longitude: 135.7681)
        
        let mode: WalkMode = destinationLocation != nil ? .destination : .timeBased
        
        return try await generateRouteProposals(
            startLocation: currentLocation,
            destinationLocation: destinationLocation,
            mode: mode,
            timeMinutes: timeMinutes,
            theme: theme,
            weather: getCurrentWeather(),
            timeOfDay: getCurrentTimeOfDay()
        )
    }
}

// MARK: - Helper Methods

private extension RouteService {
    
    /// 現在の天気を取得（ダミー実装）
    func getCurrentWeather() -> String {
        // TODO: 実際の天気APIまたはセンサーから取得
        let weathers = ["sunny", "cloudy", "rainy"]
        return weathers.randomElement() ?? "sunny"
    }
    
    /// 現在の時間帯を取得
    func getCurrentTimeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "morning"
        case 12..<17:
            return "afternoon"
        case 17..<21:
            return "evening"
        default:
            return "night"
        }
    }
}

// MARK: - Theme Mapping

extension RouteService {
    
    /// UI用のテーマ名をAPI用のテーマ名に変換
    func mapUIThemeToAPITheme(_ uiTheme: String) -> String {
        switch uiTheme {
        case "自然・公園":
            return "nature"
        case "歴史・文化":
            return "culture"
        case "グルメ・カフェ":
            return "gourmet"
        case "ショッピング":
            return "shopping"
        case "アート・ギャラリー":
            return "art"
        default:
            return "gourmet" // デフォルト
        }
    }
}
