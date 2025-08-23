//
//  MapContainerView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI
import MapKit

struct MapContainerView: View {
    @Binding var region: MKCoordinateRegion
    let currentLocation: CLLocationCoordinate2D?
    let route: [CLLocationCoordinate2D]
    let isNavigationActive: Bool
    
    var body: some View {
        ZStack {
            // 地図表示（インタラクション有効）
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: mapAnnotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    Circle()
                        .fill(annotation.color)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: 2)
                        )
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .allowsHitTesting(true) // タッチ操作を明示的に有効化
            
            // ルート線の描画（地図の表示領域に連動）
            if !route.isEmpty {
                RouteOverlayView(route: route, mapRegion: region)
                    .allowsHitTesting(false) // ルート線はタッチを通す
            }
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var mapAnnotations: [MapAnnotationItem] {
        var annotations: [MapAnnotationItem] = []
        
        // 現在地のアノテーション
        if let currentLocation = currentLocation {
            annotations.append(MapAnnotationItem(
                id: "current",
                coordinate: currentLocation,
                color: .red
            ))
        }
        
        // ルートポイントのアノテーション
        for (index, coordinate) in route.enumerated() {
            annotations.append(MapAnnotationItem(
                id: "route_\(index)",
                coordinate: coordinate,
                color: index == 0 ? .green : .blue
            ))
        }
        
        return annotations
    }
}

private struct MapAnnotationItem: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let color: Color
}

private struct RouteOverlayView: View {
    let route: [CLLocationCoordinate2D]
    let mapRegion: MKCoordinateRegion
    
    var body: some View {
        // 地図の表示領域に連動したルート線表示
        Canvas { context, size in
            guard route.count >= 2 else { return }
            
            var path = Path()
            
            // 最初のポイントに移動
            if let firstPoint = convertCoordinateToPoint(route[0], size: size) {
                path.move(to: firstPoint)
            }
            
            // 残りのポイントに線を描画
            for coordinate in route.dropFirst() {
                if let point = convertCoordinateToPoint(coordinate, size: size) {
                    path.addLine(to: point)
                }
            }
            
            context.stroke(
                path,
                with: .color(.orange),
                style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
            )
        }
    }
    
    private func convertCoordinateToPoint(_ coordinate: CLLocationCoordinate2D, size: CGSize) -> CGPoint? {
        // 現在の地図表示領域に基づく正確な座標変換
        let mapCenter = mapRegion.center
        let mapSpan = mapRegion.span
        
        // 経度と緯度の相対位置を計算
        let longitudeRatio = (coordinate.longitude - mapCenter.longitude) / mapSpan.longitudeDelta
        let latitudeRatio = (coordinate.latitude - mapCenter.latitude) / mapSpan.latitudeDelta
        
        // 画面座標に変換
        let x = size.width * 0.5 + CGFloat(longitudeRatio) * size.width
        let y = size.height * 0.5 - CGFloat(latitudeRatio) * size.height // Y軸は反転
        
        // 画面範囲内にあるかチェック
        guard x >= 0 && x <= size.width && y >= 0 && y <= size.height else {
            return nil
        }
        
        return CGPoint(x: x, y: y)
    }
}

#Preview {
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    return MapContainerView(
        region: $region,
        currentLocation: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
        route: [
            CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            CLLocationCoordinate2D(latitude: 35.6772, longitude: 139.6513),
            CLLocationCoordinate2D(latitude: 35.6780, longitude: 139.6520)
        ],
        isNavigationActive: true
    )
    .frame(height: 300)
    .padding()
}