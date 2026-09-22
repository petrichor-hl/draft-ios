//
//  DynamicHeightBottomSheet.swift
//  Draft
//
//  Created by Lam Tran  on 16/6/26.
//

import SwiftUI

struct DynamicHeightBottomSheet_iOS_16: View {
  @State private var showBottomSheet = false
  @State private var sheetHeight: CGFloat = .zero
  
  @State private var squareSize: CGFloat = 150
  
  var body: some View {
    Button {
      showBottomSheet = true
    } label: {
      Text("Show Bottom Sheet")
    }
    .sheet(isPresented: $showBottomSheet) {
      VStack(spacing: 16) {
        Text("Title")
          .font(.headline)
        
        Text("The sheet height is the sum of its children's heights.")
        
        Button {
          squareSize = squareSize == 150 ? 300 : 150
        } label: {
          Text("Change Square Size")
            .frame(width: squareSize, height: squareSize)
            .background(Color.black, in: RoundedRectangle(cornerRadius: 12))
        }
      }
      .padding()
      .background {
        GeometryReader { geometry in
          Color.clear
            .task {
              sheetHeight = geometry.size.height
            }
            .onChange(of: geometry.size.height) { _, newHeight in
              sheetHeight = newHeight
            }
          
        }
      }
      .presentationDetents([.height(sheetHeight)])
      .presentationDragIndicator(.hidden)
    }
  }
}


#Preview {
  DynamicHeightBottomSheet_iOS_16()
}
