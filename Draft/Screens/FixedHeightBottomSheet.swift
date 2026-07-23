//
//  BottomSheet.swift
//  Draft
//
//  Created by Lam Tran  on 16/6/26.
//

import SwiftUI

struct FixedHeightBottomSheet: View {
  @State private var showBottomSheet = false
  
  var body: some View {
    Button {
      showBottomSheet = true
    } label: {
      Text("Show Bottom Sheet")
    }
    .sheet(isPresented: $showBottomSheet) {
      Text("Hello World!")
        .presentationDetents([.height(600)])
        .presentationDragIndicator(.visible)
      
      Button {
        showBottomSheet = false
      } label: {
        Text("Close")
      }
    }
    
  }
}

#Preview {
  FixedHeightBottomSheet()
}
