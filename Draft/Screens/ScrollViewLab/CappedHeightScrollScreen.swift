//
//  CappedHeightScrollScreen.swift
//  Draft
//
//  Case B — khung CO theo content, chặn trên ở 500pt.
//  .frame(maxHeight: 500) KHÔNG làm được việc này: ScrollView tham lam
//  trên trục scroll, nhận trọn 500 được đề nghị rồi báo ngược lên 500.
//  Phải đo chiều cao content trước, rồi .frame(height: min(đo được, 500)).
//

import SwiftUI

struct CappedHeightScrollScreen: View {
  var body: some View {
    Text("TODO")
      .navigationTitle("B. Cap 500pt")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    CappedHeightScrollScreen()
  }
}
