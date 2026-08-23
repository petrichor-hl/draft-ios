//
//  WaterGoalSystemPickerSheet.swift
//  Draft
//
//  Mục tiêu nước uống — dựng bằng `Picker` + `.pickerStyle(.wheel)` CÓ SẴN của
//  SwiftUI. Một cột, bước không đều (250ml), có nhãn đơn vị.
//
//  Đây là bản đối chứng của kho: rẻ nhất, ~15 dòng. Trước khi bỏ công tự dựng
//  bánh xe, đo xem bánh xe hệ thống đi được tới đâu.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  ĐÃ ĐO: `Picker(.wheel)` CHỈNH ĐƯỢC GÌ, KHÔNG CHỈNH ĐƯỢC GÌ
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Đo trên iPhone 16 Pro simulator. Năm thí nghiệm, kết quả thực tế:
//
//  ┌──────────────────────────────────────┬────────────────────────────────────┐
//  │ Thử                                  │ Kết quả ĐO ĐƯỢC                    │
//  ├──────────────────────────────────────┼────────────────────────────────────┤
//  │ Không set height (intrinsic)         │ 7 hàng, 2000 → 3500                │
//  │ `.frame(height: 300)` + `.clipped()` │ Y HỆT. Bánh xe vẫn 7 hàng, đúng vị  │
//  │                                      │ trí cũ. Chỉ hộp layout to ra nên    │
//  │                                      │ title bị đẩy lên. Thừa khoảng trắng │
//  │ `.frame(height: 160)` + `.clipped()` │ 5 hàng, 2000 → 3000, nhưng hàng     │
//  │                                      │ trên/dưới cùng bị CẮT NGANG THÂN    │
//  │                                      │ CHỮ — cắt pixel, không phải bớt hàng│
//  │ `.frame(height: 60)` trên row content│ KHÔNG TÁC DỤNG. Giống hệt intrinsic │
//  │ `.labelsHidden()` bỏ đi              │ Không khác gì — `.wheel` đứng tự do  │
//  │                                      │ không vẽ nhãn                       │
//  └──────────────────────────────────────┴────────────────────────────────────┘
//
//  ## Ranh giới: `.wheel` ánh xạ xuống `UIPickerView`
//
//  SwiftUI đưa từng dòng vào `viewForRow` dưới dạng một view được host. Nên:
//  BÊN TRONG dòng thì tự do, QUANH dòng là của UIKit và không lộ ra.
//
//    ✓ Làm được          │  ✗ Không làm được
//    ────────────────────┼──────────────────────────────────────────────
//    Nội dung dòng       │  Chiều cao hàng / giãn cách giữa các hàng
//    `.font()`           │  Số hàng nhìn thấy  ← cắt được, không đếm được
//    Momentum, snap      │  Phối cảnh cong (hàng xa tâm bị nén và nghiêng)
//    Haptic mỗi khấc     │  Plinth: bề rộng, màu, bo góc
//    (miễn phí)          │
//
//  SwiftUI đo dòng CHỈ để lấy bề rộng. Chiều cao thì UIPickerView tự tính từ
//  font rồi ép mọi dòng vào con số đó — `.frame`, `.padding` trên row đều bị
//  nuốt. Đòn bẩy duy nhất cho chiều cao hàng là CỠ CHỮ, mà đổi cỡ chữ là đổi
//  luôn chữ: không tách rời được "chữ 32pt, hàng 60pt".
//
//  Nhãn đơn vị (`ml`) buộc phải nằm NGOÀI picker để không cuộn theo — nên nó
//  cũng nằm ngoài plinth. Không có cách nào có cả hai.
//
//  ## Khi nào dùng được, khi nào không
//
//  ĐỦ nếu chấp nhận trông như bánh xe iOS chuẩn: cong, plinth ôm đúng bề rộng
//  picker, số hàng và chiều cao hàng do hệ thống quyết. Đổi lại được momentum,
//  snap, haptic và accessibility miễn phí.
//
//  KHÔNG ĐỦ nếu thiết kế yêu cầu bất kỳ điều nào sau: hàng phẳng cách đều,
//  chiều cao hàng cụ thể, số hàng cụ thể, plinth trải rộng hơn cột số, hay cỡ
//  chữ lớn mà hàng không giãn theo.
//
//  Khi không đủ thì phải tự dựng. Trên iOS 16 đường ngắn nhất là UITableView +
//  `scrollViewWillEndDragging`: nó LÀ một UIScrollView nên có sẵn momentum, cho
//  phép nắn điểm dừng về đúng hàng, và tái dùng cell nên hàng nghìn dòng vẫn
//  nhẹ. Cả bốn dòng ✗ ở trên khi đó thành tham số.
//
//  ⚠️ Cảnh báo về phép đo: chạy trên simulator iOS 26.5. KIỂU PLINTH của
//     UIPickerView đã đổi qua các phiên bản iOS, nên nếu ship xuống bản thấp
//     hơn thì phải xem lại trên bản đó.
//

import SwiftUI

struct WaterGoalSystemPickerSheet: View {
  @Binding var valueMl: Int

  @Environment(\.dismiss) private var dismiss
  @State private var index = 0

  static let step = 250
  static let range = 2000...6000

  static let values: [Int] = Array(
    stride(from: range.lowerBound, through: range.upperBound, by: step)
  )

  var body: some View {
    VStack(spacing: 0) {
      Text("Điều chỉnh mục tiêu nước uống")
        .font(.system(size: 20, weight: .semibold))
        .padding(.top, 28)

      wheel
        .padding(.vertical, 24)

      Button {
        valueMl = Self.values[index]
        dismiss()
      } label: {
        Text("Cập nhật")
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 18)
          .background(Color.black, in: .capsule)
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
    .onAppear {
      // Giá trị đang lưu có thể không nằm trên lưới (2600 chẳng hạn) — bắt về
      // hàng gần nhất thay vì rơi về đầu danh sách.
      //
      // ⚠️ `onAppear` chạy SAU lần render đầu, nên bánh xe dựng ở index 0 rồi
      //    mới nhảy về đúng hàng. Bản `Picker` này nhảy nhanh nên không thấy;
      //    bản tự dựng có thể lộ ra một nháy. Cách tránh: khởi tạo `@State`
      //    ngay trong `init` bằng `State(initialValue:)`.
      index = Self.values.enumerated()
        .min { abs($0.element - valueMl) < abs($1.element - valueMl) }?
        .offset ?? 0
    }
  }

  /// Bánh xe hệ thống. Xem khối kết luận đầu file để biết cái gì chỉnh được và
  /// cái gì không.
  ///
  /// Ba chi tiết đáng nhớ ở đây:
  ///
  /// 1. `.frame(height: 60)` trên `Text` là **cố ý để lại** làm bằng chứng: nó
  ///    hoàn toàn không có tác dụng. Ai đọc code này mà định thử lại thì khỏi
  ///    mất công.
  ///
  /// 2. Nhãn `ml` nằm NGOÀI picker để không cuộn theo — nhưng cũng vì thế nó
  ///    nằm ngoài plinth mà iOS tự vẽ. Mockup muốn plinth trải qua cả `ml`.
  ///    Không có cách nào có cả hai với `Picker`.
  ///
  /// 3. 🐛 `Text("\(Self.values[i])")` nội suy `Int` nên bị format theo locale:
  ///    ra **2.500** chứ không phải **2500**. Đây là lỗi thật, không phải
  ///    thẩm mỹ — và nó cũng đang có ở hàng list gọi sheet này. Sửa bằng
  ///    `Text(String(Self.values[i]))` hoặc `Text(verbatim:)`.
  ///
  /// `Picker("")` để nhãn rỗng là **mất tên cho VoiceOver**. Cách đúng là cho
  /// nhãn thật rồi `.labelsHidden()` — VoiceOver đọc, màn hình không vẽ.
  private var wheel: some View {
    HStack(spacing: 12) {
      Picker("", selection: $index) {
        ForEach(Self.values.indices, id: \.self) { i in
          Text("\(Self.values[i])")
            .font(.system(size: 32, weight: .semibold))
            .frame(height: 60)
            .tag(i)
        }
      }
      .pickerStyle(.wheel)
      .frame(width: 200)
      .clipped()

      Text("ml")
        .font(.system(size: 17, weight: .medium))
        .foregroundStyle(.secondary)
        .frame(width: 40, alignment: .leading)
    }
  }
}
