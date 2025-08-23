//
//  WalkRepositoryProtocol.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/24.
//

import Foundation

protocol WalkRepositoryProtocol {
    /// ハニカムマップ用の散歩データを取得
    /// - Parameter bbox: 地図の表示領域を示すバウンディングボックス（例: "min_lng,min_lat,max_lng,max_lat"）
    /// - Returns: 指定領域内の散歩データ一覧
    func getWalks(bbox: String?) async throws -> WalksResponse
    
    /// 特定の散歩の詳細データを取得
    /// - Parameter walkId: 散歩のID
    /// - Returns: 散歩の詳細データ（追体験用データ）
    func getWalkDetail(walkId: String) async throws -> WalkDetailResponse
}
