//
//  FullScreenCover.swift
//  Draft
//
//  Created by Lam Tran  on 24/6/26.
//

import SwiftUI

struct FullScreenCover: View {
  @State private var isPresenting = false
  
  var body: some View {
    Button {
      isPresenting.toggle()
    } label: {
      Text("Present Full-Screen Cover")
    }
    .fullScreenCover(isPresented: $isPresenting) {
      // onDismiss
      print("This is when the Cover is completely closed")
    } content: {
      VStack {
        
        Text("A full-screen modal view.")
          .font(.title)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        Button {
          isPresenting.toggle()
        } label: {
          Text("Close")
            .fontWeight(.bold)
            .foregroundStyle(Color.black)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 24)
      }
      .background(Color.blue)
    }
    
  }
}

#Preview {
  FullScreenCover()
}
