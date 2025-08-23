//
//  RouteStepsView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI

struct RouteStepsView: View {
    let steps: [RouteStep]
    let storyText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // セクションヘッダー
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.purple)
                    .font(.system(size: 16))
                
                Text(storyText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Text("道のり")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            // ステップリスト
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(steps, id: \.stepNumber) { step in
                        RouteStepRow(step: step)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxHeight: 300)
        }
    }
}

private struct RouteStepRow: View {
    let step: RouteStep
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // ステップ番号
            Circle()
                .fill(stepBackgroundColor)
                .frame(width: 32, height: 32)
                .overlay {
                    if step.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    } else {
                        Text("\(step.stepNumber)")
                            .foregroundColor(stepNumberColor)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
            
            // ステップ内容
            VStack(alignment: .leading, spacing: 4) {
                Text(step.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(step.distance)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(stepRowBackgroundColor, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(stepBorderColor, lineWidth: step.stepType == .current ? 2 : 1)
        )
    }
    
    private var stepBackgroundColor: Color {
        switch step.stepType {
        case .completed:
            return .green
        case .current:
            return .orange
        case .upcoming:
            return .gray.opacity(0.3)
        }
    }
    
    private var stepNumberColor: Color {
        switch step.stepType {
        case .completed:
            return .white
        case .current:
            return .white
        case .upcoming:
            return .primary
        }
    }
    
    private var stepRowBackgroundColor: Color {
        switch step.stepType {
        case .completed:
            return .green.opacity(0.1)
        case .current:
            return .orange.opacity(0.2)
        case .upcoming:
            return .gray.opacity(0.05)
        }
    }
    
    private var stepBorderColor: Color {
        switch step.stepType {
        case .completed:
            return .green.opacity(0.3)
        case .current:
            return .orange
        case .upcoming:
            return .gray.opacity(0.3)
        }
    }
}