//
//  NavigationHeaderView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI

struct NavigationHeaderView: View {
    let remainingTime: String
    let remainingDistance: String
    let routeTitle: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            // 戻るボタン
            Button(action: onDismiss) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("戻る")
                        .font(.system(size: 16))
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            // ナビゲーション状態
            HStack(spacing: 8) {
                Circle()
                    .fill(.blue)
                    .frame(width: 32, height: 32)
                    .overlay {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                    }
                
                Text(routeTitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        
        // 時間・距離情報
        HStack(spacing: 40) {
            InfoItem(
                icon: "clock",
                text: remainingTime,
                color: .blue
            )
            
            InfoItem(
                icon: "map",
                text: remainingDistance,
                color: .green
            )
        }
        .padding(.vertical, 8)
    }
}

private struct InfoItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 14))
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}
