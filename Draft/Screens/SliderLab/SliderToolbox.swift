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
//  2 — Thanh âm lượng: một thumb, chạm đâu nhảy đó rồi kéo bám, nhãn % nổi lên
//      lúc kéo. Hai hàng dùng CHUNG một giá trị để so hai cách làm icon loa.
//      Chi tiết ở `VolumeSlider`.
//
//  ĐÃ ĐO (iPhone 18 Pro, iOS 27) — `DragGesture(minimumDistance: 0)` nằm trong
//  `List` thì GIÀNH được touch: vuốt dọc mà đặt ngón lên thanh kéo thì List
//  không cuộn, và cú vuốt đó còn rơi vào nhánh "chạm đâu nhảy đó" nên đổi luôn
//  giá trị. Đặt ngón ở chỗ khác — chữ, khoảng trống — thì List cuộn bình
//  thường. Cái giá của kiểu chạm-là-nhảy: trong danh sách cuộn được, mọi cú
//  vuốt lỡ tay trên thanh đều thành một lần chỉnh giá trị.
//

import SwiftUI

struct SliderToolbox: View {
  @State private var carb = 45
  @State private var protein = 35
  @State private var fat = 20

  @State private var volume = 60

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

      Section {
        VStack(alignment: .leading, spacing: 4) {
          Text(verbatim: "variableValue")
            .font(.caption)
            .foregroundStyle(.secondary)

          VolumeSlider(percent: $volume, icon: .variableValue)
        }
        .padding(.vertical, 4)

        VStack(alignment: .leading, spacing: 4) {
          Text(verbatim: "đổi symbol theo ngưỡng")
            .font(.caption)
            .foregroundStyle(.secondary)

          VolumeSlider(percent: $volume, icon: .threshold)
        }
        .padding(.vertical, 4)
      } header: {
        Text("2 — Thanh âm lượng")
      } footer: {
        Text(
          """
          Hai hàng chung MỘT giá trị, chỉ khác cách vẽ icon. Kéo hàng nào cũng \
          được, hàng kia chạy theo.

          Chạm đâu nhảy đó rồi kéo bám: startLocation lo cú nhảy, translation \
          lo phần kéo tiếp. Thumb chỉ đi được quãng width − 28 chứ không phải \
          width, nên lúc đổi toạ độ chạm về phần trăm phải trừ nửa thumb — \
          thiếu phép trừ đó thì chạm sát mép phải không bao giờ ra 100%.

          Nhãn % chỉ hiện khi ngón tay còn trên thanh. Nó là overlay của thumb \
          nên đi theo thumb sẵn, không có phép tính vị trí ngang nào riêng.
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
