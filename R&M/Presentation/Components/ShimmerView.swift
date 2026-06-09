//
//  ShimmerView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct ShimmerView: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                stops: [
                    .init(color: Color.gray.opacity(0.25), location: 0),
                    .init(color: Color.gray.opacity(0.45), location: 0.3),
                    .init(color: Color.gray.opacity(0.25), location: 0.6)
                ],
				startPoint: .init(x: self.phase, y: 0.5),
				endPoint: .init(x: self.phase + 1, y: 0.5)
            )
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
				self.phase = 1
            }
        }
    }
}
