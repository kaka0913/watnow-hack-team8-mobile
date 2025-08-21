//
//  RouteStepsView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI

struct RouteStepsView: View {
    let steps: [RouteStep]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // セクションヘッダー
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.purple)
                    .font(.system(size: 16))
                
                Text("背景の蜜蜂が紡ぐ、古き良き商店街の物語")
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
            LazyVStack(spacing: 8) {
                ForEach(steps, id: \.stepNumber) { step in
                    RouteStepRow(step: step)
                }
            }
            .padding(.horizontal, 16)
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

#Preview {
    let sampleSteps = [
        RouteStep(
            stepNumber: 1,
            description: "商店街入口へ向かう",
            distance: "200m",
            isCompleted: true,
            stepType: .completed
        ),
        RouteStep(
            stepNumber: 2,
            description: "老舗和菓子店「豊月堂」を発見",
            distance: "150m",
            isCompleted: false,
            stepType: .current
        ),
        RouteStep(
            stepNumber: 3,
            description: "昭和レトロ喫茶「黄昏」で休憩",
            distance: "300m",
            isCompleted: false,
            stepType: .upcoming
        )
    ]
    
    return RouteStepsView(steps: sampleSteps)
}