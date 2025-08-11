//
//  PostSelectionCard.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/11.
//

import SwiftUI

struct PostSelectionCard: View {
    @Bindable var viewModel: WalkSummaryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🍯")
                    .font(.title2)
                Text("ハニカムマップに投稿しますか?")
                    .font(.headline)
            }
            
            HStack(spacing: 12) {
                Button(action: { viewModel.shouldPost = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("投稿する")
                                .font(.body)
                                .foregroundColor(.black)
                            Text("他の人にも体験してもらう")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { viewModel.shouldPost = false }) {
                    HStack {
                        Image(systemName: "heart")
                            .foregroundColor(.gray)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("投稿しない")
                                .font(.body)
                                .foregroundColor(.black)
                            Text("自分だけの思い出にする")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    PostSelectionCard(viewModel: WalkSummaryViewModel())
}
