//
//  HoneyBeeIcon.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI

struct HoneyBeeIcon: View {
    let onTap: (() -> Void)?
    @State private var isAnimating = false
    
    init(onTap: (() -> Void)? = nil) {
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            Circle()
                .fill(.yellow)
                .frame(width: 50, height: 50)
                .overlay {
                    Text("🐝")
                        .font(.system(size: 28))
                        .offset(y: isAnimating ? -2 : 2)
                }
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct RouteDeviationDialog: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // 背景のオーバーレイ
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented = false
                    }
                }
            
            // ダイアログ本体
            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    HStack(spacing: 8) {
                        Text("🐝")
                            .font(.title2)
                        
                        Text("新しい冒険を始めたようですね？")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // メッセージ
                Text("ルートから外れたことを検知しました")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                
                // ボタン
                VStack(spacing: 12) {
                    // メインボタン（新しいルートで進む）
                    Button(action: {
                        print("新しいルートで進むが選択されました")
                        withAnimation(.easeOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 16))
                            Text("新しいルートで進む")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    // サブボタン（元のルートに戻る）
                    Button(action: {
                        print("元のルートに戻るが選択されました")
                        withAnimation(.easeOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        Text("元のルートに戻る")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
            .scaleEffect(isPresented ? 1.0 : 0.8)
            .opacity(isPresented ? 1.0 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
        }
    }
}

#Preview {
    HoneyBeeIcon()
        .padding()
}