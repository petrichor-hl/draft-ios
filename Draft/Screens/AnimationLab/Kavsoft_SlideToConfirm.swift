//
//  Kavsoft_SlideToConfirm.swift
//  Draft
//
//  Created by Lam Tran  on 14/7/26.
//
//  Video: https://www.youtube.com/watch?v=IetZJH-QaS0
//

import SwiftUI

struct Kavsoft_SlideToConfirm: View {
    @State private var sliderID = UUID()
    
    let config = SlideToConfirm.Config(
        idleText: "Swipe to Pay",
        onSwipeText: "Confirms Payment",
        confirmationText: "Success!",
        tint: .green,
        foregroundColor: .white,
        height: 70
    )
    
    var body: some View {
        VStack {
            Spacer()
            
            SlideToConfirm(config: config) {
                print("Swiped!")
            }
            .id(sliderID)
            .padding(.bottom, 20)
            
            Button("Reset") {
                sliderID = UUID()
            }
            .buttonStyle(.bordered)
            .padding(.bottom, 20)
        }
    }
}

struct SlideToConfirm: View {
    var config: Config
    var onSwiped: () -> Void
    
    @State private var offsetX: CGFloat = 0
    @State private var animateText = false
    @State private var isCompleted = false
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            let knobSize = size.height
            let maxLimit = size.width - knobSize
            
            let progress: CGFloat = isCompleted ? 1 : offsetX / maxLimit
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(
                        .gray.opacity(0.25)
                        .shadow(
                            .inner(color: .black.opacity(0.2), radius: 10)
                        )
                    )
                
                // Tint Capsule
                let extraCapsuleWith = maxLimit * progress
                Capsule()
                    .fill(config.tint.gradient)
                    .frame(width: knobSize + extraCapsuleWith, height: knobSize)
                
                idleTextView(size, progress: progress)
                
                onSwipeTextView(size, progress: progress)
                
                knobView(size, progress: progress, maxLimit: maxLimit)
            }
        }
        .frame(height: isCompleted ? config.height - 20 : config.height)
        .containerRelativeFrame(.horizontal) { value, _ in  // (1) đặt rộng = 80%
            let ratio: CGFloat = isCompleted ? 0.4 : 0.8
            return min(value * ratio, 300) // (2) chặn trần ở 300
        }
        .allowsHitTesting(!isCompleted)
    }
    
    func knobView(_ size: CGSize, progress: CGFloat, maxLimit: CGFloat) -> some View {
        return Circle()
            .fill(.background)
            .padding(6)
            .frame(width: size.height, height: size.height)
            .overlay {
                Image(systemName: "chevron.right")
                    .font(.title3.bold())
                    .opacity(1 - progress)
                    .blur(radius: progress * 110)
                
                Image(systemName: "checkmark")
                    .font(.title3.bold())
                    .opacity(progress)
                    .blur(radius: (1 - progress) * 10)
            }
            .contentShape(.circle)
            .scaleEffect(isCompleted ? 0.8 : 1, anchor: .center)
            .offset(x: isCompleted ? maxLimit : offsetX)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offsetX = max(0, min(value.translation.width, maxLimit))
                    }
                    .onEnded { _ in
                        if offsetX == maxLimit {
                            onSwiped()
                            
                            withAnimation(.smooth) {
                                isCompleted = true
                            }
                        } else {
                            withAnimation(.smooth) {
                                offsetX = 0
                            }
                        }
                    }
            )
    }
    
    func idleTextView(_ size: CGSize, progress: CGFloat) -> some View {
        Text(config.idleText)
            .foregroundStyle(.gray.opacity(0.6))
            .overlay {
                SlideToConfirmShimmer(isActive: !isCompleted)
                    .mask(alignment: .leading) {
                        Text(config.idleText)
                    }
                    .blendMode(.softLight)
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.leading, size.height / 2)
            .mask {
                // NOTE để sau này tìm hiểu kỹ hơn
                Rectangle()
                    .scale(x: 1 - progress, anchor: .trailing)
            }
            .frame(height: size.height)
    }
    
    // Confirmation Text View
    func onSwipeTextView(_ size: CGSize, progress: CGFloat) -> some View {
        ZStack {
            Text(config.onSwipeText)
                .opacity(isCompleted ? 0 : 1)
                .blur(radius: isCompleted ? 10 : 0)
            
            Text(config.confirmationText)
                .opacity(!isCompleted ? 0 : 1)
                .blur(radius: !isCompleted ? 10 : 0)
        }
        .fontWeight(.semibold)
        .foregroundStyle(config.foregroundColor)
        .frame(maxWidth: .infinity)
        .padding(.trailing, size.height * (isCompleted ? 0.8 : 1) / 2)
        .mask {
            Rectangle()
                .scale(x: progress, anchor: .leading)
        }
    }
    
    struct Config {
        var idleText: String
        var onSwipeText: String
        var confirmationText: String
        var tint: Color
        var foregroundColor: Color
        var height: CGFloat
    }
}

private struct SlideToConfirmShimmer: View {
    var isActive: Bool

    var body: some View {
        if isActive {
            GeometryReader { geometry in
                let size = geometry.size
                let stripeWidth: CGFloat = 15
                let startX = (size.width - stripeWidth) / 2 - size.width / 1.8

                Rectangle()
                    .fill(.foreground)
                    .frame(width: stripeWidth, height: size.width)
                    .offset(x: startX, y: (size.height - size.width) / 2)
                    .keyframeAnimator(initialValue: CGFloat.zero, repeating: true) { stripe, progress in
                        stripe.offset(x: size.width * 1.2 * progress)
                    } keyframes: { _ in
                        MoveKeyframe(CGFloat.zero)
                        LinearKeyframe(CGFloat(1), duration: 1.5)
                    }
            }
        }
    }
}
