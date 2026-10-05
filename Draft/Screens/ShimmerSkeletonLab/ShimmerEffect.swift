//
//  ShimmerEffect.swift
//  Draft

import SwiftUI

extension View {
    func shimmer(
        color: Color = .white,
        useGradient: Bool = false
    ) -> some View {
        self.modifier(
            ShimmerModifier(color: color, useGradient: useGradient)
        )
    }
}

private struct ShimmerModifier: ViewModifier {

    let color: Color
    let useGradient: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if useGradient {
                        // Caller chọn gradient để tạo vệt sáng trên Text.
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
                    } else {
                        // Mặc định: vệt sáng mềm cho skeleton.
                        let size = geometry.size
                        let skeletonWidth = size.width / 2
                        let blurRadius = max(skeletonWidth / 2, 30)
                        let blurDiameter = blurRadius * 2
                        let minX = -(skeletonWidth + blurDiameter)
                        let maxX = size.width + blurDiameter

                        Rectangle()
                            .fill(color)
                            .frame(width: skeletonWidth, height: size.height * 2)
                            .frame(height: size.height)
                            .blur(radius: blurRadius)
                            .rotationEffect(.init(degrees: 5))
                            .keyframeAnimator(initialValue: minX, repeating: true) { content, value in
                                content.offset(x: value)
                            } keyframes: { _ in
                                LinearKeyframe(
                                    maxX,
                                    duration: 1.5
                                )
                            }
                    }
                }
                .mask { content }   // Đặt .mask ở đây
            )
            // Không đặt .mask ở đây
    }
}
