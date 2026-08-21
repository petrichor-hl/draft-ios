//
//  SelectionScreen.swift
//  Draft
//
//  Generator D — UISelectionFeedbackGenerator.
//
//  Điểm cốt lõi: một cú selection đơn độc gần như không cảm thấy gì.
//  Nó chỉ có nghĩa khi ghép thành CHUỖI.
//

import SwiftUI
import UIKit

struct SelectionScreen: View {
  @State private var generator = UISelectionFeedbackGenerator()
  @State private var notch: Double = 0
  @State private var fruit = 0

  var body: some View {
    List {
      Section {
        Button {
          generator.selectionChanged()
        } label: {
          Text("selectionChanged()")
            .font(.system(.body, design: .monospaced))
        }
      } header: {
        Text("Một cú đơn lẻ")
      } footer: {
        Text("Gần như không cảm thấy gì, và đó là CHỦ Ý. Đây là haptic nhẹ nhất hệ thống. Dùng nó cho một sự kiện đơn lẻ là dùng sai API.")
      }

      Section {
        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Text("Kéo qua từng nấc")
            Spacer()
            Text("\(Int(notch))")
              .monospacedDigit()
              .foregroundStyle(.secondary)
          }
          Slider(value: $notch, in: 0...20, step: 1)
        }
        .padding(.vertical, 4)
        .onChange(of: notch) { _, _ in
          // Mỗi lần nhảy nấc là một selectionChanged() — đúng công dụng thiết kế
          generator.selectionChanged()
        }
      } header: {
        Text("Ghép thành chuỗi")
      } footer: {
        Text("""
          Kéo chậm qua 20 nấc: từng cú tách nhẹ ghép lại thành cảm giác BÁNH RĂNG, giống vặn núm cơ. \
          Đây mới là thứ class này được sinh ra để làm.

          Để ý nấc ĐẦU hơi trễ, các nấc sau khớp hoàn hảo — chính chuỗi rung đã tự giữ engine nóng, \
          đúng cơ chế bạn đo ở màn A. Muốn nấc đầu cũng khớp thì gọi prepare() lúc gesture bắt đầu.
          """)
      }

      Section {
        Picker("Chọn quả", selection: $fruit) {
          ForEach(Self.fruits.indices, id: \.self) { index in
            Text(Self.fruits[index]).tag(index)
          }
        }
        .pickerStyle(.wheel)
      } header: {
        Text("Đối chứng: Picker hệ thống")
      } footer: {
        Text("""
          Màn này KHÔNG gắn haptic nào cho Picker. Nhưng cứ quay thử — nó vẫn tách từng nấc.

          Đó là UIKit tự bắn selection feedback bên trong. Bài học: các control dựng sẵn đã có haptic riêng, \
          bạn thêm nữa là rung đúp. Chỉ tự gọi khi làm control TỰ VẼ.
          """)
      }
    }
    .navigationTitle("Selection")
    .navigationBarTitleDisplayMode(.inline)
  }

  // Danh sách dài để bánh xe quay được đà — chuỗi selection càng dài
  // thì cảm giác bánh răng càng rõ. Năm mục thì quay chưa kịp cảm đã hết.
  private static let fruits = [
    "Xoài", "Ổi", "Chôm chôm", "Măng cụt", "Sầu riêng",
    "Thanh long", "Vải", "Nhãn", "Bưởi", "Dứa",
    "Đu đủ", "Mít", "Na", "Hồng xiêm", "Vú sữa",
    "Khế", "Roi", "Bơ", "Chuối", "Dừa",
  ]
}

#Preview {
  NavigationStack {
    SelectionScreen()
  }
}
