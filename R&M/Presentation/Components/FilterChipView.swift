//
//  FilterChipView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct FilterChipView: View {
    let label: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .bold()
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.accentColor.opacity(0.15))
        .foregroundStyle(Color.accentColor)
        .clipShape(Capsule())
    }
}
