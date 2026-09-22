//
//  TextFieldInSheet.swift
//  Draft
//
//  Kết luận: Bàn phím lên thì iOS đẩy cả sheet lên cho đáy sheet nằm ngay trên bàn phím;
//  nếu detent + keyboard vượt chiều cao màn thì sheet tự co lại.
//

import SwiftUI

struct TextFieldInSheet: View {
  @State private var isPresented = false
  @State private var text = ""

  var body: some View {
    Button {
      isPresented = true
    } label: {
      Text("Show Bottom Sheet")
    }
    .sheet(isPresented: $isPresented) {
      VStack(spacing: 16) {
        Text("Detent .height(600)")
          .font(.headline)

        TextField("Nhập gì đó", text: $text)
          .textFieldStyle(.roundedBorder)

        Spacer()

        Text("Đáy sheet")
          .font(.caption)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background(Color.yellow.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
      }
      .padding()
      .presentationDetents([.height(600)])
      .presentationDragIndicator(.visible)
    }
  }
}

#Preview {
  TextFieldInSheet()
}
