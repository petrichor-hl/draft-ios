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
//  3 — Thanh theo mốc 0 · 25 · 50 · 75 · 100, bản hệ thống: `Slider(ticks:)`
//      của iOS 26, có rào `#available` vì target là 18.6.
//
//  4 — Cùng bộ mốc đó nhưng tự dựng: thumb snap hẳn sang mốc gần nhất ngay
//      trong lúc kéo, nhãn là bóng thoại có đuôi. Chi tiết ở `StepSlider`.
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

  @State private var level = 50
  /// Bản hệ thống ăn Double và KHÔNG chung state với bản tự dựng — để nhìn
  /// được giá trị thô của nó rơi vào đâu sau mỗi cú kéo.
  @State private var levelNative: Double = 50

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

      Section {
        VStack(alignment: .leading, spacing: 8) {
          Text(verbatim: "Slider(ticks:) — iOS 26 · \(String(format: "%.1f", levelNative))")
            .font(.caption)
            .monospacedDigit()
            .foregroundStyle(.secondary)

          // Target của Draft là iOS 18.6 (mức 26.5 nằm ở project nhưng target
          // đè lên), nên API ticks phải có rào. Nhánh else chính là cách duy
          // nhất để có snap trước iOS 26: tham số `step:`.
          if #available(iOS 26, *) {
            Slider(value: $levelNative, in: 0...100) {
              Text("Mức")
            } ticks: {
              // `id: \.self` chứ không phải bản rút gọn: bản kia đòi phần tử
              // conform Identifiable, mà Double thì không.
              SliderTickContentForEach([0, 25, 50, 75, 100], id: \.self) { SliderTick($0) }
            }
          } else {
            Slider(value: $levelNative, in: 0...100, step: 25)
          }
        }
        .padding(.vertical, 4)
      } header: {
        Text("3 — Thanh theo mốc, bản hệ thống")
      } footer: {
        Text(
          """
          Snap là tên của hành vi: giá trị dính vào mốc gần nhất. Mấy chấm \
          trên track gọi là tick.

          API thật của iOS 26 — SliderTick và SliderTickContentForEach. Con số \
          cạnh nhãn là giá trị THÔ. Thả ở lưng chừng hai mốc thì nó vẫn về \
          đúng mốc, 75.0 rồi 50.0, không có số lẻ: khai báo tick là kéo theo \
          cả snap chứ không chỉ vẽ vạch cho dễ nhắm.

          Target của Draft là iOS 18.6 — mức 26.5 nằm ở project nhưng target \
          đè lên — nên chỗ này phải có rào #available. Nhánh dự phòng dùng \
          step: 25, đúng cách duy nhất để có snap trước iOS 26.
          """
        )
      }

      Section {
        VStack(alignment: .leading, spacing: 8) {
          Text(verbatim: "tự dựng · \(level)")
            .font(.caption)
            .monospacedDigit()
            .foregroundStyle(.secondary)

          StepSlider(value: $level, steps: [0, 25, 50, 75, 100])
            .padding(.top, 28)
        }
        .padding(.vertical, 4)
      } header: {
        Text("4 — Thanh theo mốc, tự dựng")
      } footer: {
        Text(
          """
          Dựng theo ảnh mẫu: track cắt làm hai mảnh chừa khoảng hở cho thumb, \
          tick ẩn đi khi rơi vào khoảng hở đó, nhãn là bóng thoại có đuôi vẽ \
          bằng Path. So với section trên: Apple vẽ tick NẰM DƯỚI track, ở đây \
          tick nằm ĐÈ LÊN track.

          Snap bỏ luôn được biến anchor của món 2 — vị trí ngón tay quyết định \
          tất cả, vì kết quả còn phải đi qua một phép làm tròn về mốc nên lệch \
          vài pt không đổi được gì.

          Mốc không bắt buộc cách đều: vị trí tính theo GIÁ TRỊ, và snap tìm \
          mốc gần nhất cũng theo giá trị chứ không theo pixel.

          Mỗi lần qua mốc có rung .selection.
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
