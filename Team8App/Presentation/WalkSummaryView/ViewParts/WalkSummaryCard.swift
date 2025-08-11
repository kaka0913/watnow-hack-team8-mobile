//
//  WalkSummaryCard.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/11.
//

import SwiftUI

struct WalkSummaryCard: View {
    let viewModel: WalkSummaryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(viewModel.title)
                    .font(.headline)
                Spacer()
            }
            
            Text(viewModel.subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 16) {
                Label(viewModel.time, systemImage: "clock")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Label(viewModel.distance, systemImage: "location")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(viewModel.visitedCount)")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    WalkSummaryCard(viewModel: WalkSummaryViewModel())
}
