//
//  LineInterpolationScreen.swift
//  Draft
//
//  Phần mở rộng của Types #4 — Line. Tách ra màn riêng vì LineChartScreen đã
//  đủ dài với năm section về series và trục.
//
//  ĐỀ BÀI — .interpolationMethod quyết định ĐOẠN NỐI giữa hai điểm, không
//  đụng tới chính các điểm. Chín kiểu, đọc từ Charts.swiftinterface của iOS 27
//  SDK; ba cái nhận tham số nên không liệt kê hết bằng CaseIterable được:
//
//    .linear                    thẳng, mặc định
//    .cardinal                  cong
//    .cardinal(tension:)        cong, chỉnh độ căng
//    .catmullRom                cong, đi sát điểm hơn
//    .catmullRom(alpha:)        cong, chỉnh tham số
//    .monotone                  cong nhưng KHÔNG vọt quá giá trị điểm
//    .stepStart                 bậc thang, đổi ngay tại điểm đầu
//    .stepCenter                bậc thang, đổi ở giữa hai điểm
//    .stepEnd                   bậc thang, đổi tại điểm sau
//
//  CẦN ĐO:
//    1. Kiểu cong nào VỌT QUÁ giá trị thật? Với nhịp tim hay tồn kho thì
//       đường vọt lên trên đỉnh là vẽ ra số chưa từng có.
//    2. Ba kiểu bậc thang khác nhau ở đâu — đổi bậc trước, giữa, hay sau.
//

import Charts
import SwiftUI

private let day = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 23))!

/// Dữ liệu THƯA, bảy điểm cách nhau ba giờ. Với mẫu dày như màn Line (360
/// điểm, mỗi phút một mẫu) thì mọi kiểu nội suy trông y hệt nhau — khoảng
/// cách giữa hai điểm liền kề nhỏ hơn một pixel thì nối kiểu gì cũng vậy.
private let sparse: [HeartSample] = {
  let calendar = Calendar.current
  return [62, 88, 70, 140, 120, 165, 95].enumerated().map { offset, bpm in
    HeartSample(
      time: calendar.date(byAdding: .hour, value: offset * 3 + 3, to: day)!,
      bpm: bpm
    )
  }
}()

private let interpolations: [(name: String, method: InterpolationMethod)] = [
  ("linear — mặc định", .linear),
  ("cardinal", .cardinal),
  ("cardinal(tension: 0.8)", .cardinal(tension: 0.8)),
  ("catmullRom", .catmullRom),
  ("catmullRom(alpha: 0.2)", .catmullRom(alpha: 0.2)),
  ("monotone", .monotone),
  ("stepStart", .stepStart),
  ("stepCenter", .stepCenter),
  ("stepEnd", .stepEnd),
]

struct LineInterpolationScreen: View {
  var body: some View {
    List {
      ForEach(interpolations, id: \.name) { item in
        Section {
          Chart(sparse) { point in
            LineMark(
              x: .value("Giờ", point.time),
              y: .value("BPM", point.bpm)
            )
            .interpolationMethod(item.method)
            .foregroundStyle(.pink)

            // Chấm đánh dấu ĐIỂM DỮ LIỆU THẬT — mọi kiểu nội suy đều đi qua
            // đúng những chấm này, chỉ khác đoạn nối giữa chúng.
            PointMark(
              x: .value("Giờ", point.time),
              y: .value("BPM", point.bpm)
            )
            .symbolSize(18)
            .foregroundStyle(.pink)
          }
          .chartXAxis(.hidden)
          .chartYAxis(.hidden)
          .frame(height: 110)
        } header: {
          Text(item.name)
            .font(.caption.monospaced())
        }
      }
    }
    .navigationTitle("interpolationMethod")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    LineInterpolationScreen()
  }
}
