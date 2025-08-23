//
//  CurrentLocationCard.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI

struct CurrentLocationCard: View {
    let locationName: String
    let storyText: String
    
    var body: some View {
        VStack(spacing: 8) {
            // 位置アイコンとロケーション名
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.red)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("現在地: \(locationName)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(storyText)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    CurrentLocationCard(
        locationName: "商店街入口付近",
        storyText: "物語が始まります..."
    )
    .padding()
}