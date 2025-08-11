//
//  DiscoveryCard.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/11.
//

import SwiftUI

struct DiscoveryCard: View {
    let visitedSpots: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日の発見:")
                .font(.headline)
                .foregroundColor(.black)
            
            ForEach(visitedSpots, id: \.self) { spot in
                HStack {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 32, height: 32)
                    Text(spot)
                        .font(.body)
                }
                .padding(.vertical, 4)
                
                if spot != visitedSpots.last {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    DiscoveryCard(visitedSpots: [
        "伝統なお菓子店「伝統堂」",
        "レトロなカフェ「レトカ」",
        "手作り雑貨店「手雑店」"
    ])
}
