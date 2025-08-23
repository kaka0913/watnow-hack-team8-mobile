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
            
            // ルート線の描画（簡易版）
            if !route.isEmpty {
                RouteOverlayView(route: route)
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
    
    var body: some View {
        // 簡易的なルート線表示（実際のMapKitのMKPolylineを使用することを推奨）
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
                with: .color(.blue),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
            )
        }
    }
    
    private func convertCoordinateToPoint(_ coordinate: CLLocationCoordinate2D, size: CGSize) -> CGPoint? {
        // 簡易的な座標変換（実際の実装では正確な地図座標変換が必要）
        let x = size.width * 0.5 + CGFloat((coordinate.longitude - 139.6503) * 10000)
        let y = size.height * 0.5 - CGFloat((coordinate.latitude - 35.6762) * 10000)
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
            CLLocationCoordinate2D(latitude: 35.6772, longitude: 139.6513)
        ],
        isNavigationActive: true
    )
    .frame(height: 300)
    .padding()
}