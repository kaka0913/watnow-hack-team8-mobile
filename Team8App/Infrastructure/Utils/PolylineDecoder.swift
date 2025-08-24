//
//  PolylineDecoder.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/23.
//

import Foundation
import CoreLocation
import MapKit

struct PolylineDecoder {
    /// エンコードされたポリライン文字列をCLLocationCoordinate2Dの配列にデコード
    /// - Parameter encodedPolyline: Google Polyline Algorithm 5でエンコードされた文字列
    /// - Returns: デコードされた座標の配列
    static func decode(_ encodedPolyline: String) -> [CLLocationCoordinate2D] {
        print(encodedPolyline)
        print("🔍 PolylineDecoder.decode() 開始")
        print("   - 入力ポリライン長: \(encodedPolyline.count)")
        print("   - 先頭20文字: \(String(encodedPolyline.prefix(20)))")
        
        guard !encodedPolyline.isEmpty else {
            print("⚠️ PolylineDecoder: 空のポリライン文字列が渡されました")
            return []
        }
        
        var coordinates: [CLLocationCoordinate2D] = []
        var index = encodedPolyline.startIndex
        let endIndex = encodedPolyline.endIndex
        
        var lat = 0
        var lng = 0
        var pointCount = 0
        
        while index < endIndex {
            // 緯度をデコード
            let latResult = decodeValue(from: encodedPolyline, startIndex: &index, endIndex: endIndex)
            guard let decodedLat = latResult else {
                print("❌ PolylineDecoder: 緯度のデコードに失敗しました (point \(pointCount))")
                break
            }
            lat += decodedLat
            
            // 経度をデコード
            let lngResult = decodeValue(from: encodedPolyline, startIndex: &index, endIndex: endIndex)
            guard let decodedLng = lngResult else {
                print("❌ PolylineDecoder: 経度のデコードに失敗しました (point \(pointCount))")
                break
            }
            lng += decodedLng
            
            // 座標に変換（1e5で除算して小数点座標に戻す）
            let latitude = Double(lat) / 1e5
            let longitude = Double(lng) / 1e5
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            coordinates.append(coordinate)
            
            // 最初の5個と最後の5個の座標を詳細ログ
            if pointCount < 5 || coordinates.count <= 5 {
                print("   - Point \(pointCount): (\(latitude), \(longitude))")
            }
            
            pointCount += 1
        }
        
        print("✅ PolylineDecoder: \(coordinates.count)個の座標をデコードしました")
        if coordinates.count > 0 {
            print("   - 開始地点: (\(coordinates.first!.latitude), \(coordinates.first!.longitude))")
            print("   - 終了地点: (\(coordinates.last!.latitude), \(coordinates.last!.longitude))")
            
            // 座標の妥当性をチェック
            let validCount = coordinates.filter { coordinate in
                abs(coordinate.latitude) <= 90 && abs(coordinate.longitude) <= 180
            }.count
            print("   - 有効座標数: \(validCount)/\(coordinates.count)")
            
            // 重複座標の確認
            let uniqueCoordinates = Set(coordinates.map { "\($0.latitude),\($0.longitude)" })
            print("   - ユニーク座標数: \(uniqueCoordinates.count)")
        }
        
        return coordinates
    }
    
    /// ポリライン文字列から1つの値をデコード
    /// - Parameters:
    ///   - encodedPolyline: エンコードされたポリライン文字列
    ///   - startIndex: デコード開始位置（参照渡しで更新される）
    ///   - endIndex: 文字列の終端
    /// - Returns: デコードされた値、失敗時はnil
    private static func decodeValue(from encodedPolyline: String, startIndex: inout String.Index, endIndex: String.Index) -> Int? {
        var result = 0
        var shift = 0
        
        while startIndex < endIndex {
            let character = encodedPolyline[startIndex]
            startIndex = encodedPolyline.index(after: startIndex)
            
            guard let asciiValue = character.asciiValue else {
                print("❌ PolylineDecoder: ASCII値の取得に失敗: \(character)")
                return nil
            }
            
            let value = Int(asciiValue) - 63
            
            result |= (value & 0x1F) << shift
            shift += 5
            
            // 終了ビットをチェック（bit 5が0の場合は終了）
            if (value & 0x20) == 0 {
                break
            }
        }
        
        // 符号を適用（LSBが1の場合は負の値）
        if (result & 1) != 0 {
            result = ~(result >> 1)
        } else {
            result = result >> 1
        }
        
        return result
    }
}

// MARK: - Test Data and Helper Functions
extension PolylineDecoder {
    /// デコード結果が有効かどうかをチェック
    /// - Parameter coordinates: チェックする座標配列
    /// - Returns: 有効な場合はtrue
    static func isValidCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> Bool {
        guard !coordinates.isEmpty else { return false }
        
        // 座標の妥当性をチェック
        for coordinate in coordinates {
            if abs(coordinate.latitude) > 90 || abs(coordinate.longitude) > 180 {
                print("❌ 無効な座標が検出されました: (\(coordinate.latitude), \(coordinate.longitude))")
                return false
            }
        }
        
        return true
    }
    
    /// 座標配列から地図の表示領域を計算
    /// - Parameter coordinates: 座標配列
    /// - Returns: 地図の表示領域、座標が空の場合はnil
    static func calculateMapRegion(from coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion? {
        guard !coordinates.isEmpty else { return nil }
        
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        guard let minLat = latitudes.min(),
              let maxLat = latitudes.max(),
              let minLng = longitudes.min(),
              let maxLng = longitudes.max() else {
            return nil
        }
        
        let centerLat = (minLat + maxLat) / 2
        let centerLng = (minLng + maxLng) / 2
        
        let spanLat = max(maxLat - minLat, 0.01) * 1.2 // 10%のマージンを追加
        let spanLng = max(maxLng - minLng, 0.01) * 1.2
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng),
            span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLng)
        )
    }
}
