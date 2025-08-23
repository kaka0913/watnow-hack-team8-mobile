//
//  ThemeSelectionCard.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/18.
//

import SwiftUI

struct ThemeSelectionCard: View {
    @Binding var selectedTheme: String
    @Binding var showThemeSelection: Bool
    let themePlaceholder: String
    let availableThemes: [String]
    let onThemeSelect: (String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(.orange)
                Text("散歩のテーマ")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Button(action: {
                showThemeSelection.toggle()
            }) {
                HStack {
                    Text(selectedTheme.isEmpty ? themePlaceholder : selectedTheme)
                        .foregroundColor(selectedTheme.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(showThemeSelection ? 180 : 0))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .sheet(isPresented: $showThemeSelection) {
                ThemeSelectionSheet(
                    themes: availableThemes,
                    selectedTheme: $selectedTheme,
                    onSelect: { theme in
                        onThemeSelect(theme)
                        showThemeSelection = false
                    }
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Theme Selection Sheet
struct ThemeSelectionSheet: View {
    let themes: [String]
    @Binding var selectedTheme: String
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(themes, id: \.self) { theme in
                Button(action: {
                    onSelect(theme)
                }) {
                    HStack {
                        Text(theme)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedTheme == theme {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("テーマを選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}
