//
//  Kavsoft_SlideToConfirm.swift
//  Draft
//
//  Created by Lam Tran  on 14/7/26.
//
//  Video: https://www.youtube.com/watch?v=IetZJH-QaS0
//  Progress: 7 phut 19 giay

import SwiftUI

struct Kavsoft_SlideToConfirm: View {
  var body: some View {
    VStack {
      Spacer()
      
      let config = SlideToConfirm.Config(
        idleText: "Swipe to Pay",
        onSwipeText: "Confirms Payment",
        confirmationText: "Success!",
        tint: .green,
        foregroundColor: .white
      )
      
      SlideToConfirm(config: config) {
        print("Swiped!")
      }
      .padding(.bottom, 20)
    }
  }
}

#Preview {
  Kavsoft_SlideToConfirm()
}

struct SlideToConfirm: View {
  var config: Config
  var onSwiped: () -> Void
  
  @State private var offsetX: CGFloat = 0
  @State private var animateText = false
  
  var body: some View {
    GeometryReader { geometry in
      let size = geometry.size
      
      let knobSize = size.height
      let maxLimit = size.width - knobSize
      
      let progress: CGFloat = offsetX / maxLimit
      
      ZStack(alignment: .leading) {
        Capsule()
          .fill(
            .gray.opacity(0.25)
            .shadow(
              .inner(color: .black.opacity(0.2), radius: 10)
            )
          )
        
        HStack(spacing: 0) {
          KnobView(size, progress: progress, maxLimit: maxLimit)
            .zIndex(1)
          
          ShimmerTextView(size, progress: progress)
        }
      }
    }
    .frame(height: config.height)
    .containerRelativeFrame(.horizontal) { value, _ in  // (1) đặt rộng = 80%
      let ratio: CGFloat = 0.8
      return min(value * ratio, 300) // (2) chặn trần ở 300
    }
  }
  
  func KnobView(_ size: CGSize, progress: CGFloat, maxLimit: CGFloat) -> some View {
    
    return Circle()
      .fill(.background)
      .padding(6)
      .frame(width: size.height, height: size.height)
      .overlay {
        Image(systemName: "chevron.right")
          .font(.title3.bold())
      }
      .contentShape(.circle)
      .offset(x: offsetX)
      .gesture(
        DragGesture()
          .onChanged { value in
            offsetX = max(0, min(value.translation.width, maxLimit))
          }
          .onEnded { _ in
            
          }
      )
  }
  
  func ShimmerTextView(_ size: CGSize, progress: CGFloat) -> some View {
    Text(config.idleText)
      .foregroundStyle(.gray.opacity(0.6))
      .overlay {
        Rectangle()
          .frame(height: 15)
          .rotationEffect(.init(degrees: 90))
          .visualEffect { [animateText] content, proxy in
            content
              .offset(x: -proxy.size.width / 1.8)
              .offset(x: animateText ? proxy.size.width * 1.2 : 0)
          }
          .mask(alignment: .leading) {
            Text(config.idleText)
          }
          .blendMode(.softLight)
      }
      .fontWeight(.semibold)
      .frame(maxWidth: .infinity)
      .padding(.trailing, size.height / 2)
      .mask {
        // NOTE để sau này tìm hiểu kỹ hơn
        Rectangle()
          .scale(x: 1 - progress, anchor: .trailing)
      }
      .frame(height: size.height)
      .task {
        withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
          animateText = true
        }
      }
  }
  
  struct Config {
    var idleText: String
    var onSwipeText: String
    var confirmationText: String
    var tint: Color
    var foregroundColor: Color
    var height: CGFloat = 70
  }
}
