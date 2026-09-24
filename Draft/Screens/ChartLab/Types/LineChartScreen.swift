//
//  LineChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — LineMark:
//    .interpolationMethod(.catmullRom / .monotone / .stepEnd)  dáng đường
//    .lineStyle(StrokeStyle(lineWidth:dash:))                  nét đứt
//    series: .value(...)                                       tách nhiều đường
//
//  Cái bẫy để dành cho Garmin: dữ liệu khuyết vài giờ thì LineMark NỐI
//  THẲNG qua khoảng trống, không tự đứt. Muốn đứt đoạn phải tách segment
//  bằng tham số series:. Dựng cặp đối chứng có/không tách để thấy rõ.
//
//  ĐÃ ĐO trên simulator, 360 mẫu — một mẫu mỗi phút, khuyết hẳn 09:00–15:00.
//
//  A NÓI DỐI MỘT CÁCH THUYẾT PHỤC. Sáu tiếng khuyết biến thành một đoạn
//  thẳng dốc thoai thoải từ 66 lên 80, trông hệt như nhịp tim tăng đều
//  đặn suốt buổi. Không dấu hiệu nào cho thấy đó là khoảng trống.
//
//  Tệ hơn BarMark khuyết dữ liệu ở Basics màn 2: ở đó chart chỉ im lặng,
//  còn ở đây nó BỊA ra một câu chuyện. Trục Date đặt đúng vị trí hai đầu,
//  nhưng LineMark vẫn nối hai điểm liền kề bất kể chúng cách nhau bao lâu.
//
//  B tách series thì đứt đúng chỗ. Ngưỡng cứng kiểu "trước 12 giờ là sáng"
//  chỉ chạy với bộ dữ liệu này; splitSegments tính từ khoảng cách thời gian
//  nên xử lý được cả ngày có ba bốn khoảng trống rải rác. Ngưỡng gap chỉnh
//  theo tần suất đo của thiết bị — Garmin đo vài phút một lần thì 10–15
//  phút hợp hơn 5.
//
//  series: KHÔNG ĐỤNG TỚI MÀU. Hai chart cùng hồng dù B có nhiều series.
//  Nó nhận Int cũng được, không bắt buộc String, và không sinh legend —
//  khác hẳn foregroundStyle(by:). Charts phân biệt rõ scale nào để vẽ chú
//  giải, scale nào chỉ để nhóm điểm.
//
//  TRỤC X 06/09/12/15 giờ là Charts tự chọn, không có modifier nào. Nó tự
//  chọn bước 3 giờ theo miền dữ liệu và bề rộng khung, tự bỏ nhãn 18 giờ
//  vì sát mép, tự viết "06 giờ" theo locale Việt. Garmin cần bước 4 giờ và
//  trọn 24 giờ bất kể dữ liệu nằm đâu — thứ phải nói rõ ở Basics #5.
//

import Charts
import SwiftUI

struct HeartSample: Identifiable {
  let id = UUID()
  let time: Date
  let bpm: Int
  var segment = 0
}

/// Duyệt theo thứ tự thời gian, gặp khoảng trống lớn hơn `gap` thì mở đoạn mới.
/// Ngưỡng chỉnh theo tần suất đo thật của thiết bị.
private func splitSegments(_ samples: [HeartSample], gap: TimeInterval) -> [HeartSample] {
  var result: [HeartSample] = []
  var segment = 0

  for (index, sample) in samples.enumerated() {
    if index > 0, sample.time.timeIntervalSince(samples[index - 1].time) > gap {
      segment += 1
    }
    var item = sample
    item.segment = segment
    result.append(item)
  }
  return result
}

private let samples: [HeartSample] = {
  let calendar = Calendar.current
  let day = calendar.date(from: DateComponents(year: 2026, month: 9, day: 23))!

  func at(_ minute: Int) -> Date {
    calendar.date(byAdding: .minute, value: minute, to: day)!
  }

  /// Một mẫu mỗi phút trong [from, to). `shape` nhận tiến độ 0…1 rồi trả về
  /// nhịp nền; `noise` cộng thêm để đường có răng cưa như đồng hồ đo thật.
  func run(
    from: Int,
    to: Int,
    noise: Double,
    shape: (Double) -> Double
  ) -> [HeartSample] {
    (from..<to).map { minute in
      let progress = Double(minute - from) / Double(to - from)
      let bpm = shape(progress) + Double.random(in: -noise...noise)
      return HeartSample(time: at(minute), bpm: Int(bpm.rounded()))
    }
  }

  // Sáng đeo đồng hồ, trưa tháo ra, chiều đeo lại và có tập luyện.

  // 06:00–09:00 nghỉ ngơi: nhịp nền thấp, dao động chậm
  let morning = run(from: 6 * 60, to: 9 * 60, noise: 3) { progress in
    64 + 6 * sin(progress * 8 * .pi)
  }

  // 15:00–18:00 tập luyện: leo lên đỉnh rồi hạ, chồng thêm nhịp lên xuống
  // theo hiệp để có các đỉnh nhọn như biểu đồ Garmin
  let evening = run(from: 15 * 60, to: 18 * 60, noise: 5) { progress in
    80 + 95 * sin(progress * .pi) + 14 * sin(progress * 14 * .pi)
  }

  return morning + evening
}()

private let segmented = splitSegments(
  samples,
  gap: 5 * 60 // 5 phút
)

struct LineChartScreen: View {
  var body: some View {
    List {
      Section("A — LineMark thường") {
        Chart(samples) { sample in
          LineMark(
            x: .value("Giờ", sample.time),
            y: .value("BPM", sample.bpm)
          )
          .foregroundStyle(.pink)
        }
        .frame(height: 200)
      }

      Section {
        Chart(segmented) { sample in
          LineMark(
            x: .value("Giờ", sample.time),
            y: .value("BPM", sample.bpm),
            series: .value("Đoạn", sample.segment)
          )
          .foregroundStyle(.pink)
        }
        .frame(height: 200)
      } header: {
        Text("B — tách series, tự tìm chỗ đứt")
      } footer: {
        Text("Ngưỡng 5 phút: mẫu cách nhau một phút, nên năm phút không có gì là coi như tháo đồng hồ. Chạy được với mọi bộ dữ liệu, kể cả nhiều khoảng trống rải rác.")
      }
    }
  }
}

#Preview {
  NavigationStack {
    LineChartScreen()
  }
}
