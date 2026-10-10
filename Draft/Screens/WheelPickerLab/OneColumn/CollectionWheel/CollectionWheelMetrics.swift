import CoreGraphics

/// Số đo của RIÊNG bản collection.
///
/// Cố ý không dùng chung với bản table — xem ghi chú ở `TableWheelMetrics`.
///
/// ## Hai nghĩa của "chiều cao hàng" — tách ra là hiểu hết
///
///     BƯỚC CUỘN     `rowHeight`, ĐỀU cho mọi hàng.
///                   Dùng cho `contentSize`, snap, `contentInset`.
///
///     CHIỀU CAO VẼ  `rowHeightRamp`, KHÁC nhau theo vòng.
///                   Chỉ layout biết, chỉ ảnh hưởng hình.
///
/// Mỗi hàng chiếm đúng `rowHeight` quãng cuộn bất kể được vẽ to hay nhỏ. Đây là
/// cách `UIPickerView` làm: lưới cuộn đều, chỉ CÁCH VẼ bị bóp méo — hàng nằm
/// trên mặt hình trụ nên càng xoay ra xa càng dẹt.
///
/// Giữ lưới cuộn đều bảo toàn một bất biến: hàng ở tâm có khoảng cách 0, mà hàm
/// nén luôn cho f(0) = 0 — nên chỗ bánh xe DỪNG và chỗ hàng đó ĐƯỢC VẼ luôn
/// trùng nhau, không sai số tích luỹ dù cuộn qua bao nhiêu hàng.
struct CollectionWheelMetrics {
  /// Chiều cao VẼ của hàng theo vòng tính từ tâm: [tâm, kề, xa…].
  /// Phần tử cuối áp dụng cho mọi vòng xa hơn.
  ///
  /// Chỉ chi phối VỊ TRÍ (bước cuộn và lượng nén). Cỡ chữ do `scaleRamp` lo
  /// riêng — xem ghi chú ở đó.
  var rowHeightRamp: [CGFloat] = [64, 60, 52]

  var visibleRows: Int = 5
  var fontSize: CGFloat = 40

  /// Tỉ lệ co CHỮ theo vòng.
  ///
  /// Property riêng, KHÔNG suy ra từ `rowHeightRamp` — dù ban đầu từng làm vậy.
  /// Hai mảng đo hai đại lượng khác nhau và cần chỉnh độc lập:
  ///
  ///     rowHeightRamp  → khoảng cách giữa các hàng bị nén bao nhiêu
  ///     scaleRamp      → chữ nhỏ đi bao nhiêu
  ///
  /// Chứng cứ chúng độc lập: đổi ramp từ [44,40,32] sang [64,60,52] thì lượng
  /// nén KHÔNG đổi (vẫn kéo vào 6 và 16pt) vì nén phụ thuộc HIỆU giữa các chiều
  /// cao; nhưng tỉ lệ co lại nhẹ hẳn (0.727 → 0.813) vì tỉ lệ phụ thuộc THƯƠNG.
  /// Buộc chúng vào một mảng thì mỗi lần chỉnh cái này lại hỏng cái kia.
  var scaleRamp: [CGFloat] = [1, 0.85, 0.62]

  /// Độ mờ theo vòng. Cũng để riêng, cùng lý do.
  var alphaRamp: [CGFloat] = [1, 0.3, 0.2]

  static let `default` = CollectionWheelMetrics()

  // MARK: - Suy ra

  /// Bước cuộn danh nghĩa = khoảng cách TÂM giữa hàng giữa và hàng kề nó.
  ///
  /// Chọn đúng con số này để hàng đang chọn và hai hàng kề bám ngón tay **1:1**;
  /// nén chỉ bắt đầu từ vòng 2 trở ra, nơi mắt không soi. Lấy số khác (64 chẳng
  /// hạn) thì ngay vùng trung tâm đã lệch — chỗ tệ nhất để có sai số.
  var rowHeight: CGFloat { (drawnHeight(atRing: 0) + drawnHeight(atRing: 1)) / 2 }

  /// Chiều cao hàng ở tâm — dùng cho plinth.
  var centerRowHeight: CGFloat { drawnHeight(atRing: 0) }

  /// Chiều cao khung để `visibleRows` hàng hiện ĐỦ, không hàng nào cụt.
  ///
  /// ⚠️ KHÔNG phải `visibleRows × rowHeight`. Đó là quãng CUỘN, còn đây là quãng
  ///    VẼ — mà vẽ thì đã bị nén. Lấy nhầm công thức kia thì khung rộng dư và
  ///    hàng thứ 6 ló lên một nửa ở mép.
  ///
  ///    Với [64, 60, 52] và 5 hàng: vòng ngoài cùng là 2, tâm ở 118, nửa chiều
  ///    cao 26 → mép ngoài 144 → khung 288. (Lưới đều sẽ là 5 × 62 = 310.)
  var height: CGFloat {
    let outerRing = max(visibleRows - 1, 0) / 2
    return 2 * (ringCenter(outerRing) + drawnHeight(atRing: outerRing) / 2)
  }

  func drawnHeight(atRing ring: Int) -> CGFloat {
    rowHeightRamp[min(max(ring, 0), rowHeightRamp.count - 1)]
  }

  // MARK: - Bóp méo vị trí

  /// Tâm hàng khi VẼ cách tâm khung nhìn bao nhiêu điểm, cho khoảng cách danh
  /// nghĩa `distance` (đơn vị: số hàng, số thực).
  ///
  /// Cộng dồn nửa-chiều-cao dọc đường:
  ///
  ///     vòng 0: 0
  ///     vòng 1: 64/2 + 60/2 = 62
  ///     vòng 2: 62 + 60/2 + 52/2 = 118     (lưới đều sẽ là 124 → kéo vào 6)
  ///     vòng 3: 118 + 52 = 170             (lưới đều sẽ là 186 → kéo vào 16)
  ///
  /// `distance` là số thực vì lúc cuộn nó ở giữa hai vòng — nội suy tuyến tính
  /// để chuyển động liên tục chứ không nhảy bậc.
  func drawnOffset(fromCenter distance: CGFloat) -> CGFloat {
    let clamped = max(distance, 0)
    let lower = Int(clamped)
    let t = clamped - CGFloat(lower)
    let a = ringCenter(lower)
    return a + (ringCenter(lower + 1) - a) * t
  }

  /// Nội suy tuyến tính trên một thang rời rạc theo vòng.
  func ramp(_ values: [CGFloat], at distance: CGFloat) -> CGFloat {
    guard let last = values.last else { return 1 }
    let clamped = min(max(distance, 0), CGFloat(values.count - 1))
    let lower = Int(clamped)
    guard lower + 1 < values.count else { return last }
    let t = clamped - CGFloat(lower)
    return values[lower] + (values[lower + 1] - values[lower]) * t
  }

  /// Tâm của vòng thứ `ring`, tính từ tâm khung nhìn.
  private func ringCenter(_ ring: Int) -> CGFloat {
    guard ring > 0 else { return 0 }
    var y: CGFloat = 0
    for i in 1...ring {
      y += (drawnHeight(atRing: i - 1) + drawnHeight(atRing: i)) / 2
    }
    return y
  }
}
