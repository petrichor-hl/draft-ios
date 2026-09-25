//
//  SliderToolbox.swift
//  Draft
//
//  Kho slider — dựng lại các thanh kéo gặp trong app thật.
//
//  1 — Thanh chia macro, clone từ sheet "Nutrition goal" của Dietfit. Ba số
//      carb/protein/fat luôn cộng thành 100, nên cái kéo được chỉ là HAI biên
//      giữa ba đoạn. Chi tiết ở `MacroSplitBar`.
//

import SwiftUI

struct SliderToolbox: View {
  @State private var carb = 45
  @State private var protein = 35
  @State private var fat = 20

  /// Bản gốc nhận từ hồ sơ; ở đây cắm cứng đúng con số trong ảnh chụp màn hình.
  private let dailyCalories = 2000

  private var totalIsValid: Bool { carb + protein + fat == 100 }

  var body: some View {
    List {
      Section {
        VStack(spacing: 16) {
          MacroSplitBar(carb: $carb, protein: $protein, fat: $fat)

          MacroRatioInputRow(
            dailyCalories: dailyCalories,
            carb: carb,
            protein: protein,
            fat: fat
          )

          if !totalIsValid {
            Text("Tổng ba macro phải bằng 100%.")
              .font(.subheadline)
              .foregroundStyle(.red)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: totalIsValid)
      } header: {
        Text("1 — Thanh chia macro (Dietfit)")
      } footer: {
        Text(
          """
          Mục tiêu \(dailyCalories) kcal/ngày. Kéo một trong hai thumb: mỗi thumb \
          chỉ đụng hai macro kề nó, macro còn lại đứng yên và tổng vẫn là 100 — \
          vì thứ bị sửa là BIÊN chứ không phải từng số.

          Một DragGesture duy nhất đặt trên cả dải, không phải hai gesture gắn \
          lên hai thumb: khi hai thumb chồng nhau thì hit-test hết phân biệt \
          được. Giá trị mới tính bằng mốc-lúc-bắt-đầu + translation, không cộng \
          dồn vào giá trị hiện tại.
          """
        )
      }
    }
    .navigationTitle("Slider Toolbox")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    SliderToolbox()
  }
}
