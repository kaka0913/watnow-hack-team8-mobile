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
    
    // デフォルト座標（京都河原町）
    private let defaultLocation = CLLocationCoordinate2D(latitude: 35.0041, longitude: 135.7681)
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10m移動したら更新
    }
    
    // 位置情報の許可を要求
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            errorMessage = "位置情報の使用が許可されていません。設定から許可してください。"
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    // 位置情報の取得を開始
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    // 位置情報の取得を停止
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    // 現在位置を取得（非同期）
    func getCurrentLocation() async -> CLLocationCoordinate2D {
        // 既に位置情報がある場合はそれを返す
        if let location = currentLocation {
            return location
        }
        
        // 位置情報の許可状況を確認
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 位置情報取得を開始
            startLocationUpdates()
            
            // 最大5秒間待機して位置情報を取得
            for _ in 0..<50 {
                if let location = currentLocation {
                    return location
                }
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒待機
            }
            
            // タイムアウトした場合はデフォルト位置を返す
            print("⚠️ 位置情報の取得がタイムアウトしました。デフォルト位置を使用します。")
            return defaultLocation
            
        case .denied, .restricted:
            print("⚠️ 位置情報の使用が拒否されています。デフォルト位置を使用します。")
            return defaultLocation
            
        case .notDetermined:
            print("⚠️ 位置情報の許可が未確定です。デフォルト位置を使用します。")
            return defaultLocation
            
        @unknown default:
            return defaultLocation
        }
    }
    
    // Location構造体として現在位置を取得
    func getCurrentLocationAsLocation() async -> Location {
        let coordinate = await getCurrentLocation()
        return Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location.coordinate
        errorMessage = nil
        
        print("📍 位置情報を更新しました: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "位置情報の取得に失敗しました: \(error.localizedDescription)"
        print("❌ 位置情報取得エラー: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
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
