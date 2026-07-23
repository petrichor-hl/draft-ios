//
//  SwipeToConfirm.swift
//  Draft
//
//  Created by Lam Tran  on 14/7/26.
//

import SwiftUI

struct SwipeToConfirm: View {
  // Chiều rộng của cả thanh trượt và kích thước thumb
  private let trackWidth: CGFloat = 300
  private let thumbSize: CGFloat = 60
  
  @State private var offset: CGFloat = 0
  @State private var isConfirmed = false
  
  private var maxOffset: CGFloat {
    trackWidth - thumbSize
  }
  
  private var threshold: CGFloat {
    maxOffset * 0.7
  }
  
  var body: some View {
    VStack {
      ZStack(alignment: .leading) {
        // 1. TRACK — cái nền
        Capsule()
          .fill(Color.green.opacity(0.3))
          .frame(width: trackWidth, height: thumbSize)
        
        // 2. Chữ gợi ý ở giữa
        Text(isConfirmed ? "Confirmed" : "Swipe to confirm")
          .frame(width: trackWidth, height: thumbSize)
        
        // 3. THUMB — nút tròn để kéo
        Circle()
          .fill(Color.green)
          .frame(width: thumbSize, height: thumbSize)
          .overlay(
            Image(systemName: isConfirmed ? "checkmark" : "arrow.right")
                        .foregroundColor(.white)
          )
          .offset(x: offset)
          .gesture(
            DragGesture()
              .onChanged { value in
                guard !isConfirmed else { return }
                // Kéo tới đâu, offset tới đó — nhưng KẸP trong [0, maxOffset]
                offset = max(0, min(value.translation.width, maxOffset))
                // print("offset = \(offset)")
              }
              .onEnded { _ in
                guard !isConfirmed else { return }
                
                if offset >= threshold {
                  withAnimation {
                    offset = maxOffset
                  }
                  
                  isConfirmed = true
                  // print("✅ CONFIRMED")
                } else {
                  withAnimation(.spring()) {
                    offset = 0
                  }
                }
              }
          )
        
        
      }
      // ④ Nút reset — chỉ bấm được khi đã confirmed
      Button("Reset") {
        withAnimation(.spring()) {
          offset = 0
          isConfirmed = false
        }
      }
      .disabled(!isConfirmed)
    }
    .navigationTitle("Swipe to Confirm")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    SwipeToConfirm()
  }
}
