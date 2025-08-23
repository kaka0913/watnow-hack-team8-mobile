//
//  WalkService.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/24.
//

import Foundation
import SwiftUI

class WalkService {
    static let shared = WalkService()
    private let walkRepository = WalkRepository.shared
    
    private init() {}
    
    /// ハニカムマップ用の散歩データを取得
    /// - Parameter bbox: 地図の表示領域を示すバウンディングボックス
    /// - Returns: 指定領域内の散歩データ一覧
    func getWalks(bbox: String? = nil) async throws -> WalksResponse {
        let response = try await walkRepository.getWalks(bbox: bbox)
        
        // 無効なデータをフィルタリング
        let validWalks = response.walks.filter { walk in
            let isValid = isValidWalk(walk)
            if !isValid {
                print("⚠️ 無効な散歩データをスキップ: \(walk.id) - \(walk.title)")
            }
            return isValid
        }
        
        print("✅ 有効な散歩データ: \(validWalks.count)/\(response.walks.count)件")
        return WalksResponse(walks: validWalks)
    }
    
    /// 特定の散歩の詳細データを取得
    /// - Parameter walkId: 散歩のID
    /// - Returns: 散歩の詳細データ（追体験用データ）
    func getWalkDetail(walkId: String) async throws -> WalkDetailResponse {
        return try await walkRepository.getWalkDetail(walkId: walkId)
    }
}

// MARK: - Convenience Methods

extension WalkService {
    
    /// 現在の地図表示領域内の散歩データを取得（簡単メソッド）
    /// - Parameters:
    ///   - minLongitude: 最小経度
    ///   - minLatitude: 最小緯度
    ///   - maxLongitude: 最大経度
    ///   - maxLatitude: 最大緯度
    /// - Returns: 散歩データ一覧
    func getWalksInRegion(
        minLongitude: Double,
        minLatitude: Double,
        maxLongitude: Double,
        maxLatitude: Double
    ) async throws -> WalksResponse {
        
        let bbox = "\(minLongitude),\(minLatitude),\(maxLongitude),\(maxLatitude)"
        return try await getWalks(bbox: bbox)
    }
    
    /// 現在地周辺の散歩データを取得（簡単メソッド）
    /// - Parameter radiusKm: 検索半径（キロメートル）
    /// - Returns: 現在地周辺の散歩データ一覧
    func getWalksAroundCurrentLocation() async throws -> WalksResponse {
        
        // 実際の現在地を取得
        let currentLocation = await LocationManager.shared.getCurrentLocationAsLocation()
        
        // 半径からバウンディングボックスを計算（簡易計算）
        let latDelta = 5.0 / 111.0  // 緯度1度≒111km
        let lonDelta = 5.0 / (111.0 * cos(currentLocation.latitude * .pi / 180.0))
        
        let minLat = currentLocation.latitude - latDelta
        let maxLat = currentLocation.latitude + latDelta
        let minLon = currentLocation.longitude - lonDelta
        let maxLon = currentLocation.longitude + lonDelta
        
        return try await getWalksInRegion(
            minLongitude: minLon,
            minLatitude: minLat,
            maxLongitude: maxLon,
            maxLatitude: maxLat
        )
    }
    
    /// エリア名で散歩データを検索（将来の拡張用）
    /// - Parameter areaName: エリア名
    /// - Returns: 該当エリアの散歩データ一覧
    func getWalksByAreaName(_ areaName: String) async throws -> WalksResponse {
        // 現在はbboxパラメータのみサポートされているため、全データを取得してフィルタリング
        let allWalks = try await getWalks()
        
        let filteredWalks = allWalks.walks.filter { walk in
            walk.areaName.localizedCaseInsensitiveContains(areaName)
        }
        
        return WalksResponse(walks: filteredWalks)
    }
}

// MARK: - Helper Methods

extension WalkService {
    
    /// Walk データを StoryRoute 形式に変換
    /// - Parameter walk: Walk データ
    /// - Returns: StoryRoute データ
    func convertToStoryRoute(_ walk: Walk) -> StoryRoute {
        return StoryRoute(
            id: walk.id,
            title: walk.title,
            description: walk.summary,
            duration: walk.durationMinutes,
            distance: Double(walk.distanceMeters) / 1000.0, // メートルをキロメートルに変換
            category: mapTagsToCategory(walk.tags),
            iconColor: getColorForCategory(mapTagsToCategory(walk.tags)),
            highlights: walk.tags.map { RouteHighlight(name: $0) }
        )
    }
    
    /// タグからカテゴリーをマッピング
    /// - Parameter tags: タグ配列
    /// - Returns: ルートカテゴリー
    private func mapTagsToCategory(_ tags: [String]) -> StoryRoute.RouteCategory {
        // タグの内容に基づいてカテゴリーを判定
        for tag in tags {
            switch tag.lowercased() {
            case let t where t.contains("自然") || t.contains("nature") || t.contains("公園") || t.contains("park"):
                return .nature
            case let t where t.contains("グルメ") || t.contains("gourmet") || t.contains("カフェ") || t.contains("cafe"):
                return .gourmet
            case let t where t.contains("アート") || t.contains("art") || t.contains("ギャラリー") || t.contains("gallery"):
                return .art
            default:
                continue
            }
        }
        return .gourmet // デフォルト
    }
    
    /// カテゴリーに応じた色を取得
    /// - Parameter category: ルートカテゴリー
    /// - Returns: カテゴリーに対応する色
    private func getColorForCategory(_ category: StoryRoute.RouteCategory) -> StoryRoute.RouteIconColor {
        switch category {
        case .nature:
            return .green
        case .gourmet:
            return .orange
        case .art:
            return .pink
        }
    }
}

// MARK: - Data Validation

extension WalkService {
    
    /// バウンディングボックスの形式を検証
    /// - Parameter bbox: バウンディングボックス文字列
    /// - Returns: 有効かどうか
    func isValidBbox(_ bbox: String) -> Bool {
        let components = bbox.split(separator: ",")
        guard components.count == 4 else { return false }
        
        guard let minLon = Double(components[0]),
              let minLat = Double(components[1]),
              let maxLon = Double(components[2]),
              let maxLat = Double(components[3]) else {
            return false
        }
        
        // 経度・緯度の範囲チェック
        return minLon >= -180 && maxLon <= 180 &&
               minLat >= -90 && maxLat <= 90 &&
               minLon < maxLon && minLat < maxLat
    }
    
    /// 散歩データの基本検証
    /// - Parameter walk: 散歩データ
    /// - Returns: 有効かどうか
    func isValidWalk(_ walk: Walk) -> Bool {
        // 基本的な必須フィールドのチェック
        let hasBasicData = !walk.id.isEmpty && 
                          !walk.title.isEmpty && 
                          walk.durationMinutes >= 0  // 0以上に緩和
        
        // 位置情報のチェック（nullでも有効）
        let hasValidLocation = walk.endLocation == nil || 
                             (abs(walk.endLocation?.latitude ?? 0) <= 90 &&
                              abs(walk.endLocation?.longitude ?? 0) <= 180)
        
        let isValid = hasBasicData && hasValidLocation
        
        if !isValid {
            print("🔍 データ検証詳細:")
            print("  - ID: \(walk.id.isEmpty ? "❌空" : "✅有効")")
            print("  - タイトル: \(walk.title.isEmpty ? "❌空" : "✅有効")")
            print("  - 時間: \(walk.durationMinutes)分 \(walk.durationMinutes >= 0 ? "✅" : "❌")")
            print("  - 距離: \(walk.distanceMeters)m")
            print("  - 位置情報: \(hasValidLocation ? "✅有効またはnull" : "❌無効")")
        }
        
        return isValid
    }
}
