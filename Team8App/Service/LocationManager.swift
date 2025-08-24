//
//  LocationManager.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/23.
//

import Foundation
import CoreLocation
import Combine

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    // 現在の位置情報
    var currentLocation: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var errorMessage: String?
    
    // 許可要求の制御フラグ
    private var isRequestingPermission = false
    // 位置情報更新の制御フラグ
    private var isUpdatingLocation = false
    
    // デフォルト座標（京都河原町）
    private let defaultLocation = CLLocationCoordinate2D(latitude: 35.0033, longitude: 135.7584)
    
    private override init() {
        super.init()
        setupLocationManager()
        print("😁 [LocationManager] 初期化")
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10m移動したら更新
        
        // 実際のCLLocationManagerの許可状態と同期
        authorizationStatus = locationManager.authorizationStatus
        print("😁 [LocationManager] ロケーションマネージャー設定完了")
        print("😁 [LocationManager] 現在の許可状態: \(authorizationStatus.rawValue)")
    }
    
    // 位置情報の許可を要求
    func requestLocationPermission() {
        // 実際のCLLocationManagerの状態と同期
        authorizationStatus = locationManager.authorizationStatus
        print("😁 [LocationManager] 位置情報の許可を要求中...")
        print("😁 [LocationManager] 現在の実際の許可状態: \(authorizationStatus.rawValue)")
        
        // 既に許可要求中の場合は処理をスキップ
        if isRequestingPermission {
            print("😁 [LocationManager] 既に許可要求中のため、スキップ")
            return
        }
        
        switch authorizationStatus {
        case .notDetermined:
            isRequestingPermission = true
            locationManager.requestWhenInUseAuthorization()
            print("😁 [LocationManager] 許可ダイアログ表示")
        case .denied, .restricted:
            errorMessage = "位置情報の使用が許可されていません。設定から許可してください。"
            print("😁 [LocationManager] 許可が拒否されています。エラーメッセージをセット: \(errorMessage!)")
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
            print("😁 [LocationManager] 既に許可済みのため、位置情報更新を開始")
        @unknown default:
            print("😁 [LocationManager] 不明なステータス")
            break
        }
    }
    
    // 位置情報の取得を開始
    func startLocationUpdates() {
        // 実際のCLLocationManagerの状態と同期
        authorizationStatus = locationManager.authorizationStatus
        print("😁 [LocationManager] 位置情報更新を開始中...")
        print("😁 [LocationManager] 実際の許可状態: \(authorizationStatus.rawValue)")
        
        // 既に更新中の場合はスキップ
        if isUpdatingLocation {
            print("😁 [LocationManager] 既に位置情報更新中のため、スキップ")
            return
        }
        
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            print("😁 [LocationManager] 許可がないため、再度許可を要求")
            requestLocationPermission()
            return
        }
        
        isUpdatingLocation = true
        locationManager.startUpdatingLocation()
        print("😁 [LocationManager] 位置情報更新を開始")
    }
    
    // 位置情報の取得を停止
    func stopLocationUpdates() {
        isUpdatingLocation = false
        locationManager.stopUpdatingLocation()
        print("😁 [LocationManager] 位置情報更新を停止")
    }
    
    // 現在位置を取得（非同期）
    func getCurrentLocation() async -> CLLocationCoordinate2D {
        print("😁 [LocationManager] 現在位置を非同期で取得中...")
        
        // 実際のCLLocationManagerの状態と同期
        authorizationStatus = locationManager.authorizationStatus
        
        // 古い位置情報をクリアして新しい位置情報を強制取得
        currentLocation = nil
        print("😁 [LocationManager] キャッシュされた位置情報をクリアして新しい位置情報を取得します")
        
        // 位置情報の許可状況を確認
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 位置情報取得を開始（一度だけ）
            print("😁 [LocationManager] 許可済みのため、位置情報取得を開始し、待機します...")
            if !isUpdatingLocation {
                startLocationUpdates()
            }
            
            // 最大10秒間待機して位置情報を取得
            for i in 0..<100 {
                if let location = currentLocation {
                    print("😁 [LocationManager] \(i * 100)ms 後に位置情報を取得できました: \(location.latitude), \(location.longitude)")
                    return location
                }
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒待機
            }
            
            // タイムアウトした場合でも最後に現在地取得を試行
            print("⚠️ 位置情報の取得がタイムアウトしました。最後の試行...")
            if let location = currentLocation {
                print("😁 [LocationManager] 最後の試行で位置情報を取得: \(location.latitude), \(location.longitude)")
                return location
            }
            
            // 絶対に現在地を使いたい場合は、デフォルト位置を返さずに一度更新を停止して再開
            print("⚠️ 位置情報更新を再開して再試行します...")
            stopLocationUpdates()
            startLocationUpdates()
            
            // 再試行
            for i in 0..<50 {
                if let location = currentLocation {
                    print("😁 [LocationManager] 再試行で位置情報を取得: \(location.latitude), \(location.longitude)")
                    return location
                }
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒待機
            }
            
            // 最終的にデフォルト位置を返す
            print("⚠️ 最終的にデフォルト位置を使用します。")
            return defaultLocation
            
        case .denied, .restricted:
            print("⚠️ 位置情報の使用が拒否されています。デフォルト位置を使用します。")
            return defaultLocation
            
        case .notDetermined:
            print("⚠️ 位置情報の許可が未確定です。デフォルト位置を使用します。")
            return defaultLocation
            
        @unknown default:
            print("⚠️ 不明なステータスです。デフォルト位置を使用します。")
            return defaultLocation
        }
    }
    
    // Location構造体として現在位置を取得
    func getCurrentLocationAsLocation() async -> Location {
        print("😁 [LocationManager] 現在位置をLocation構造体として取得中...")
        let coordinate = await getCurrentLocation()
        return Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { 
            print("😁 [LocationManager] 更新された位置情報がありません。")
            return 
        }
        
        currentLocation = location.coordinate
        errorMessage = nil
        
        print("📍 位置情報を更新しました: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "位置情報の取得に失敗しました: \(error.localizedDescription)"
        print("❌ 位置情報取得エラー: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        isRequestingPermission = false // 許可状態が変更されたらフラグをリセット
        
        print("😁 [LocationManager] 許可状態が変更されました: \(status.rawValue)")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ 位置情報の使用が許可されました")
            startLocationUpdates()
        case .denied, .restricted:
            print("❌ 位置情報の使用が拒否されました")
            errorMessage = "位置情報の使用が許可されていません"
        case .notDetermined:
            print("❓ 位置情報の許可が未確定です")
        @unknown default:
            break
        }
    }
}
