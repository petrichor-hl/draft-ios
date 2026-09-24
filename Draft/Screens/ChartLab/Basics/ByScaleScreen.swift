//
//  ByScaleScreen.swift
//  Draft
//
//  ĐỀ BÀI — hậu tố `by:` biến một hằng số thành scale:
//    .foregroundStyle(.blue)                        → tô xanh cứng, không legend
//    .foregroundStyle(by: .value("Loại", item.kind)) → Charts tự gán màu + tự sinh legend
//
//  Kèm .position(by:) để thấy cùng một bộ dữ liệu ra stacked hay grouped bar,
//  và .symbol(by:) cho PointMark. Legend xuất hiện là do `by:`, không phải
//  do bật tắt ở đâu cả.
//
//  ĐÃ ĐO trên simulator, mười phần tử: năm ngày × hai loại.
//
//  A LÀ CÁI BẪY. Cột T2 cao 6.200, tức 4.200 + 2.000. Hai BarMark chung
//  một toạ độ x tự cộng dồn, và vì cùng màu xanh nên biểu đồ trông hoàn
//  toàn bình thường — không dấu hiệu nào cho thấy mỗi cột là tổng của hai
//  thứ. Đọc ra "thứ Hai đi bộ 6.200 bước" trong khi thật ra là 4.200.
//
//  Stacking là MẶC ĐỊNH của BarMark, không liên quan gì tới màu và không
//  cần `by:` nào cả. Cứ hai mark chung một x là chúng chồng.
//
//  B tô màu nhưng KHÔNG tách. Vẫn 6.200, chỉ khác là nhìn thấy ranh giới
//  xanh/lục. foregroundStyle(by:) chỉ quyết định màu.
//
//  C mới tách, nhờ position(by:). T2 thành hai cột 4.200 và 2.000.
//
//  TRỤC Y ĐỔI THEO: B là 0–10.000, C là 0–6.000. Cùng một mảng, nhưng B
//  có max 9.500 (tổng của T5) còn C có max 5.500 (giá trị lớn nhất đứng
//  riêng). Charts tính domain SAU KHI đã stack, không phải từ giá trị thô.
//
//  LEGEND chỉ có ở B và C. A không có vì không có `by:` nên không có scale.
//  Gọi .chartLegend(.visible) cũng không tạo ra legend từ hư không.
//
//  D — đổi KIỂU dữ liệu đưa vào by:, từ String sang Int, thì scale đổi loại:
//  discrete thành continuous. Màu thành gradient đơn sắc xanh dương nhạt
//  đến đậm, và legend đổi hẳn hình dạng — thanh gradient ngang có trục số
//  thay cho các chấm tròn kèm nhãn. Đúng mô típ "kiểu dữ liệu quyết định
//  scale" của màn 2, lần này áp lên màu thay vì trục.
//
//  E — chartForegroundStyleScale(range: Gradient(...)) thay dải màu mặc
//  định. Đặt ở TẦNG CHART (tiền tố chart… nên nằm ngoài Chart { }, theo
//  quy tắc màn 3). Dải xanh → lục → vàng → cam → đỏ chính là bảng màu
//  Garmin dùng cho zone nhịp tim; đây là mảnh màu cần cho Toolbox.
//
//  F — tô màu cho LineMark bằng cách đưa thẳng một ShapeStyle CỨNG vào
//  foregroundStyle: LinearGradient theo chiều dọc. Đường giữ nguyên một
//  mạch và gradient phủ lên nó — xanh ở vùng thấp, đỏ ở đỉnh.
//
//  Đánh đổi: màu bám VỊ TRÍ trên khung chứ không bám GIÁ TRỊ. Đổi
//  chartYScale thì cùng một nhịp tim rơi vào độ cao khác và đổi màu theo.
//
//  Ngoài lề, sửa lại kết luận ở D/E: thang màu KHÔNG luôn kéo về 0. Với dữ
//  liệu 58–181 thì Charts chọn 50–200. Nó lấy mốc tròn quanh dữ liệu chứ
//  không cố định gồm 0.
//

import Charts
import SwiftUI

private let day = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 23))!

struct BPMPoint: Identifiable {
  let id = UUID()
  let time: Date
  let bpm: Int
}

// Nhịp tim theo giờ, 04 giờ tới 23 giờ — dải rộng để thấy màu chạy
private let bpmCurve: [BPMPoint] = [
  58, 62, 68, 75, 82, 78, 74, 80, 85, 79,
  76, 95, 165, 181, 120, 88, 82, 75, 68, 62,
]
.enumerated()
.map { offset, bpm in
  BPMPoint(
    time: Calendar.current.date(byAdding: .hour, value: offset + 4, to: day)!,
    bpm: bpm
  )
}

struct StepEntry: Identifiable {
  let id = UUID()
  let day: String
  let kind: String
  let steps: Int
}

private let entries: [StepEntry] = {
  let walk = [4200, 5100, 3300, 5500, 4200]
  let run  = [2000, 3000, 1000, 4000, 3000]
  return (0..<5).flatMap { index in
    [
      StepEntry(day: "T\(index + 2)", kind: "Đi bộ", steps: walk[index]),
      StepEntry(day: "T\(index + 2)", kind: "Chạy",  steps: run[index]),
    ]
  }
}()

struct ByScaleScreen: View {
  var body: some View {
    List {
      Section("A — hằng số, không có scale") {
        Chart(entries) { entry in
          BarMark(
            x: .value("Thứ", entry.day),
            y: .value("Bước", entry.steps)
          )
          .foregroundStyle(.blue)
        }
        .frame(height: 240)
      }

      Section("B — foregroundStyle(by:)") {
        Chart(entries) { entry in
          BarMark(
            x: .value("Thứ", entry.day),
            y: .value("Bước", entry.steps)
          )
          .foregroundStyle(by: .value("Loại", entry.kind))
        }
        .frame(height: 240)
      }

      Section("C — thêm position(by:)") {
        Chart(entries) { entry in
          BarMark(
            x: .value("Thứ", entry.day),
            y: .value("Bước", entry.steps)
          )
          .foregroundStyle(by: .value("Loại", entry.kind))
          .position(by: .value("Loại", entry.kind))
        }
        .frame(height: 240)
      }
      
      Divider()
      
      Section("D — by: với giá trị SỐ") {
        Chart(entries) { entry in
          BarMark(
            x: .value("Thứ", entry.day),
            y: .value("Bước", entry.steps)
          )
          .foregroundStyle(by: .value("Bước", entry.steps))
          .position(by: .value("Loại", entry.kind))
        }
        .frame(height: 240)
      }

      Section("E — tự chọn dải màu") {
        Chart(entries) { entry in
          BarMark(
            x: .value("Thứ", entry.day),
            y: .value("Bước", entry.steps)
          )
          .foregroundStyle(by: .value("Bước", entry.steps))
          .position(by: .value("Loại", entry.kind))
        }
        .chartForegroundStyleScale(
          range: Gradient(
            colors: [.blue, .green, .yellow, .orange, .red]
          )
        )
        .frame(height: 240)
      }

      Section {
        Chart(bpmCurve) { point in
          LineMark(
            x: .value("Giờ", point.time),
            y: .value("BPM", point.bpm)
          )
          .foregroundStyle(
            LinearGradient(
              colors: [.blue, .green, .yellow, .orange, .red],
              startPoint: .bottom,
              endPoint: .top
            )
          )
        }
        .frame(height: 240)
      } header: {
        Text("F — LineMark tô LinearGradient")
      } footer: {
        Text("foregroundStyle KHÔNG có by: nên không sinh scale, không tách series, đường vẫn liền. Màu đến từ VỊ TRÍ trên khung chứ không từ giá trị — đổi chartYScale là màu đổi theo.")
      }
    }
  }
}
