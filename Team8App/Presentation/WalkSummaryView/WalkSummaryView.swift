//
//  WalkSummaryView.swift
//  Team8App
//
//  Created by JUNNY on 2025/08/04.
//

// WalkSummaryView.swift
import SwiftUI

struct WalkSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = WalkSummaryViewModel()
    
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 1.0,blue: 0.95)
                .ignoresSafeArea()
            
            
            
            
            VStack(alignment: .leading, spacing: 10) {
                
                // header section
                VStack{
                    HStack(alignment: .center) {
                        Button(action:{
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("戻る")
                        }
                        Text("🥳散歩完了！")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer().padding(.leading, 16)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    // Walk Summary Card
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
                    
                    // Today's Discovery Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("今日の発見:")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        ForEach(viewModel.visitedSpots, id: \.self) { spot in
                            HStack {
                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 32, height: 32)
                                Text(spot)
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
                            
                            if spot != viewModel.visitedSpots.last {
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // ハニカムマップ投稿セクション
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
                                        .foregroundColor(.gray)
                                    
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
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            
        }
    }
}
    #Preview {
        WalkSummaryView()
    }

