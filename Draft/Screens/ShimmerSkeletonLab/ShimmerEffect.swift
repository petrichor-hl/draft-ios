//
//  ShimmerEffect.swift
//  Draft

import SwiftUI

extension View {
    func shimmer(
        color: Color = .white
    ) -> some View {
        self.modifier(
            ShimmerModifier(color: color)
        )
    }
}

private struct ShimmerModifier: ViewModifier {

    let color: Color

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            color.opacity(0.8),
                            Color.clear,
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 200)
                    .offset(x: -200)
                    .keyframeAnimator(initialValue: 0, repeating: true) { content, value in
                        content.offset(x: value)
                    } keyframes: { _ in
                        LinearKeyframe(
                            geometry.size.width + 200,
                            duration: 1.5
                        )
                    }

                }
                .mask { content }   // Đặt .mask ở đây
            )
            // Không đặt .mask ở đây
    }
}
