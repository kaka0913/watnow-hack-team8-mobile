//
//  LocationSettingCard.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/18.
//

import SwiftUI

struct LocationSettingCard: View {
    @Binding var startLocation: String
    @Binding var destination: String
    let destinationPlaceholder: String
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text("場所の設定")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // Start Location
                VStack(alignment: .leading, spacing: 8) {
                    Text("出発地")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("", text: $startLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(true) // 現在地固定
                }
                
                // Destination
                VStack(alignment: .leading, spacing: 8) {
                    Text("目的地")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField(destinationPlaceholder, text: $destination)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .contentShape(Rectangle()) // タップエリアを明確にする
        }
        .padding(.horizontal)
    }
}

#Preview {
    LocationSettingCard(
        startLocation: .constant("現在地から出発"),
        destination: .constant(""),
        destinationPlaceholder: "どこへ向かいますか？"
    )
}