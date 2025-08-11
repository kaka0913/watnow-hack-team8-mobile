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
                VStack {
                    // Header section
                    HeaderView(onDismiss: { dismiss() })
                    
                    // Walk Summary Card
                    WalkSummaryCard(viewModel: viewModel)
                    
                    // Today's Discovery Card
                    DiscoveryCard(visitedSpots: viewModel.visitedSpots)
                    
                    // ハニカムマップ投稿セクション
                    PostSelectionCard(viewModel: viewModel)
                    
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

