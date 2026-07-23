//
//  ScrollViewSafeAreaView.swift
//  Draft
//

import SwiftUI

struct ScrollViewSafeAreaView: View {
  
  @Environment(AppCoordinator.self) private var coordinator
  
    var body: some View {
      VStack {
        ScrollView {
          LazyVStack(spacing: 12) {
            ForEach(0..<30) { index in
              RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue)
                .frame(height: 60)
                .overlay(
                  Text("Row \(index)")
                    .foregroundStyle(.white)
                )
                .onTapGesture {
                  coordinator.pop()
                }
            }
          }
          .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        .mask {
          // Sử dụng mask ngăn cho các item trong ScrollView tràn vào top & bottom safe area
          Rectangle()
        }
      }
      .background(Color.yellow)
      .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
  ScrollViewSafeAreaView()
}
