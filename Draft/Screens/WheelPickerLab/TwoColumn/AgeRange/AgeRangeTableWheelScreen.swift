//
//  AgeRangeTableWheelScreen.swift
//  Draft
//
//  Khoảng tuổi — HAI cột (cận dưới – cận trên), dựng bằng `TableWheelPairPicker`.
//
//  Phần cuộn vẫn là `TableWheelColumn` của ca một cột, không sửa dòng nào. Cả
//  cách xếp cũng không sửa: `separator` đổi từ "." thành "–", `unitLabel` đổi từ
//  "kg" thành "tuổi", hết. Cái mới nằm ở RÀNG BUỘC — và ở chỗ đây là ca đầu
//  tiên trong kho ĐẨY sang màn hình khác thay vì mở sheet.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  1. RÀNG BUỘC THEO GIÁ TRỊ CỘT KIA, KHÔNG PHẢI THEO HẰNG SỐ
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Ca cân nặng: "chạm 200 thì phần lẻ về 0" — vế phải là một CON SỐ VIẾT SẴN.
//  Ca này: "cận dưới không được vượt cận trên" — vế phải là giá trị đang trôi
//  của cột kia. Không có mốc cố định nào để kẹp về.
//
//  Kéo theo hai hệ quả:
//
//    • ràng buộc ĐỐI XỨNG. Cân nặng chỉ hỏng theo một kiểu (lẻ ≠ 0 khi chạm
//      trần). Ở đây hỏng từ cả hai phía và hai phía là hai cảnh khác nhau: kéo
//      cận dưới LÊN quá cận trên, hoặc kéo cận trên XUỐNG dưới cận dưới.
//    • hai cột dùng CHUNG một mảng nguồn. Lần đầu trong kho. Nên `lowerIndex`
//      và `upperIndex` so sánh trực tiếp với nhau được — chúng là chỉ số vào
//      cùng một `values`, không cần quy đổi gì.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  2. ĐÙN, KHÔNG KẸP — và vì sao hai lựa chọn rơi vào HAI đường vá khác nhau
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Kéo cận dưới vượt qua cận trên, có hai cách xử:
//
//    KẸP   ghì cận dưới lại ở chỗ cận trên đang đứng.
//    ĐÙN   cho cận dưới đi tiếp, đẩy cận trên chạy lên theo.
//
//  Khác nhau ở chỗ cú sửa rơi vào cột NÀO, và đó mới là điều đáng học:
//
//    • KẸP sửa CHÍNH cột người dùng đang cuộn. Cột ấy đang `isDragging`, mà
//      `updateUIView` cố ý bỏ qua lúc đó — nên cú sửa rơi vào khoảng lặng và
//      phải chờ `settle` ở mép sau chuyển động mới kéo bánh xe về được. Tức là
//      đi lại đúng đường mà `WeightTableWheelSheet` khối 2 đã đi.
//
//    • ĐÙN sửa cột người dùng KHÔNG chạm. Cột ấy đang đứng yên, nên
//      `updateUIView` chạy được ngay — mỗi lượt `scrollViewDidScroll` ghi
//      `lowerIndex` là một lượt cột kia được đẩy theo, bám ngón tay theo thời
//      gian thực. `settle` không phải ra tay lần nào.
//
//  Chọn ĐÙN vì cả hai lý do đều nghiêng về nó:
//
//    – dùng thấy đúng hơn. Kẹp làm người dùng bế tắc khi muốn dời cả khoảng
//      lên cao: phải kéo cận trên trước rồi mới kéo được cận dưới, một thứ tự
//      bắt buộc mà không có gì trên màn hình báo cho họ biết.
//    – kho chưa đi qua đường này. Cả `Weight` lẫn `EventDate` đều sửa vào cột
//      đang cuộn; đây là ca đầu tiên sửa vào cột đứng yên.
//
//  Một chi tiết dễ tưởng là thiếu sót: cột bị đùn dời chỗ KHÔNG có animation,
//  vì `updateUIView` dùng `animated: false`. Đúng chứ không phải quên —
//  `settle` cần animation vì nó là một cú sửa MUỘN, xảy ra sau khi mọi thứ đã
//  dừng, người dùng cần thấy để hiểu. Cú đùn thì diễn ra ngay dưới ngón tay và
//  liên tục từng hàng một; thêm animation vào là để nó chạy lệch pha, lê lết
//  phía sau ngón tay.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  3. CANONICAL TỰ GÁNH RÀNG BUỘC
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Canonical ở đây là `ClosedRange<Int>`, không phải hai `Int` rời. Khác các ca
//  trước ở một điểm có sức nặng thật: KIỂU tự nó từ chối giá trị sai.
//
//      let r = 45...25      // Fatal error: Range requires lowerBound <= upperBound
//
//  (Chạy thật để lấy đúng câu đó, không phải đoán. Với hằng số viết thẳng thì
//  còn không tới được runtime — trình biên dịch gập hằng số và gãy ngay lúc
//  build.)
//
//  Nên luật ở khối 2 không phải phép lịch sự với người dùng, nó là thứ giữ cho
//  giá trị canonical CÒN DỰNG ĐƯỢC. Buông ràng buộc ra thì không phải "khoảng
//  tuổi hơi kỳ", mà là crash ngay dòng gán ở nút Cập nhật.
//
//  Đây là chiều ngược với `WheelDate` bên ca ngày sự kiện: ở đó ba `Int` rời
//  không tự biết 31/02 là sai, nên `DateWheelData` phải canh. Ở đây kiểu canh
//  hộ, đổi lại là canh bằng cách crash chứ không phải bằng cách sửa.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  4. VÌ SAO Ở ĐÂY `onChange` LẠI ĐỦ, CÒN CA NGÀY SỰ KIỆN THÌ KHÔNG
//  ═══════════════════════════════════════════════════════════════════════════
//
//  `EventDateTableWheelSheet` phải bọc binding lại vì `onChange` chạy SAU khi
//  `body` đã dựng xong, để lọt một lượt cập nhật mà `dayIndex` trỏ ra ngoài
//  `dayValues` vừa co lại — `values[30]` trên mảng 28 phần tử là crash.
//
//  Ở đây khoảng chết đó vẫn tồn tại y nguyên, nhưng vô hại: hai cột dùng chung
//  một mảng CỐ ĐỊNH 63 phần tử, không bao giờ ngắn đi. Một chỉ số hợp lệ thì
//  luôn hợp lệ, dù nó tạm thời lớn hơn chỉ số cột kia. Cái sai lọt qua khoảng
//  chết chỉ là "khoảng tuổi ngược trong một lượt render", và nó tự hết ở lượt
//  sau — không ai đọc mảng bằng nó cả.
//
//  Nói cách khác: `onChange` đủ khi hậu quả của lượt lệch là HIỂN THỊ; phải bọc
//  binding khi hậu quả là TRUY CẬP MẢNG.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  5. MÀN ĐẨY, KHÔNG PHẢI SHEET — ba thứ đổi theo
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Mọi ca trước trong kho đều mở bằng `.sheet` với detent đo được. Ca này đẩy
//  sang màn hình mới. Ba hệ quả, không cái nào là chuyện thẩm mỹ:
//
//    • `Spacer` từ CẤM thành CẦN. Sheet đo chiều cao bằng `GeometryReader` đặt
//      trong `.background`, nên một `Spacer` là đủ làm phép đo trả về detent cũ
//      và kẹt vòng lặp — xem cảnh báo ở `heightReader`. Màn đẩy không đo gì
//      cả, khung đã full màn hình sẵn, nên phải có `Spacer` thì nút mới xuống
//      đáy được thay vì dính ngay dưới bánh xe.
//
//    • tiêu đề dọn từ THÂN lên NAVIGATION BAR. Sheet không có bar nên phải tự
//      vẽ một `Text` làm tiêu đề. Ở đây có bar thật, tự vẽ thêm là hai tiêu đề
//      chồng nhau.
//
//    • "huỷ" trở thành trạng thái CÓ THẬT. Các sheet đều
//      `.interactiveDismissDisabled()`, nên đường ra duy nhất là nút Cập nhật —
//      không tồn tại khả năng thoát mà không ghi. Màn đẩy thì có nút Back và cử
//      chỉ vuốt mép, và không khoá lại được theo cách tương đương. Vì vậy state
//      cục bộ ở đây phải hiểu là BẢN NHÁP: vuốt về là vứt, chỉ nút Cập nhật mới
//      ghi ngược vào binding.
//
//  `@Environment(\.dismiss)` dùng được cho cả hai kiểu — trong `NavigationStack`
//  nó pop, trong sheet nó đóng. Không phải đổi sang `coordinator.pop()`.
//

import SwiftUI

struct AgeRangeTableWheelScreen: View {
  /// `ClosedRange` chứ không phải hai `Int` — lý do ở khối 3 đầu file.
  @Binding var range: ClosedRange<Int>

  @Environment(\.dismiss) private var dismiss
  @State private var lowerIndex: Int
  @State private var upperIndex: Int

  static let bounds = 18...80
  static let values: [Int] = Array(bounds)

  /// Khởi tạo trong `init` chứ không phải `onAppear` — lý do đầy đủ ở
  /// `WaterGoalTableWheelSheet`.
  ///
  /// Không phải kẹp thứ tự hai chỉ số ở đây, dù nghe rất nên làm: `ClosedRange`
  /// đã bảo đảm `lowerBound <= upperBound` ngay từ lúc nó tồn tại, và phép kẹp
  /// về dải dưới đây giữ nguyên thứ tự. Thêm một `min`/`max` nữa là viết code
  /// canh một trạng thái mà kiểu không cho phép có.
  init(range: Binding<ClosedRange<Int>>) {
    self._range = range
    self._lowerIndex = State(initialValue: Self.index(of: range.wrappedValue.lowerBound))
    self._upperIndex = State(initialValue: Self.index(of: range.wrappedValue.upperBound))
  }

  var body: some View {
    VStack(spacing: 0) {
      TableWheelPairPicker(
        leadingValues: Self.labels,
        leadingIndex: $lowerIndex,
        trailingValues: Self.labels,
        trailingIndex: $upperIndex,
        separator: "–",
        unitLabel: "tuổi",
        trailingWidth: 100,
        separatorWidth: 40
      )
      .padding(.horizontal, 24)
      .padding(.top, 24)
      // Hai chiều, vì khoảng bị lộn ngược được từ cả hai phía. Xem khối 1.
      .onChange(of: lowerIndex) { _, _ in pushUpper() }
      .onChange(of: upperIndex) { _, _ in pushLower() }

      // Được phép ở đây, bị cấm trong mọi sheet của kho — xem khối 5.
      Spacer()

      Button {
        // Dòng này crash nếu ràng buộc ở trên hở — xem khối 3.
        range = Self.values[lowerIndex]...Self.values[upperIndex]
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
    .navigationTitle("Khoảng tuổi")
    .navigationBarTitleDisplayMode(.inline)
  }

  /// Cả hai cột cùng đọc một mảng nhãn — tính một lần thay vì map hai lượt.
  private static let labels: [String] = values.map { String($0) }

  /// Lưới bước 1 phủ kín dải nên không cần `nearestIndex` như ca nước uống:
  /// mọi tuổi hợp lệ đều rơi đúng một hàng. Chỉ cần kẹp về dải trước khi trừ.
  private static func index(of age: Int) -> Int {
    min(max(age, bounds.lowerBound), bounds.upperBound) - bounds.lowerBound
  }

  /// Cận dưới vừa vượt lên trên cận trên → đùn cận trên đi theo.
  ///
  /// Không cần cờ chặn lặp như `enforceCeiling` bên ca cân nặng, và lý do đáng
  /// ghi ra: phép gán làm hai chỉ số BẰNG nhau, mà cả hai điều kiện đều là bất
  /// đẳng thức NGẶT — nên lượt `onChange` mà nó kích hoạt không khớp điều kiện
  /// nào và dây chuyền tự dừng sau đúng một bước.
  ///
  /// Đổi `>` thành `>=` là vòng lặp vô tận. Dấu so sánh ở đây gánh việc, không
  /// phải trang trí.
  private func pushUpper() {
    guard lowerIndex > upperIndex else { return }
    upperIndex = lowerIndex
  }

  private func pushLower() {
    guard upperIndex < lowerIndex else { return }
    lowerIndex = upperIndex
  }
}
