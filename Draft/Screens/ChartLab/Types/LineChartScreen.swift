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
//  bằng tham số series:. Năm section đi từ cái bẫy tới trục hoàn chỉnh
//  của Garmin.
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
//  TRỤC X — miền và mốc là HAI việc rời nhau, đo bằng C, D, E:
//
//    A, B  không modifier      06 / 09 / 12 / 15
//    C     chartXScale         00 / 06 / 12 / 18
//    D     AxisMarks 4 giờ     06 / 10 / 14
//    E     cả hai              00 / 04 / 08 / 12 / 16 / 20
//
//  D là section đắt nhất. .stride(by: .hour, count: 4) KHÔNG có nghĩa là
//  "chia 4 giờ kể từ nửa đêm" — nó chia 4 giờ trong MIỀN HIỆN CÓ, mà miền
//  vẫn là 06–18 do Charts tự suy từ dữ liệu. Bước đúng, điểm neo sai.
//
//  Điểm neo đến từ miền, và AxisMarks không đụng tới miền. Nên hai modifier
//  này không thay thế nhau, cũng không cái nào bao cái nào:
//    chartXScale(domain:)  trục bắt đầu và kết thúc ở đâu
//    AxisMarks(values:)    trong khoảng đó thì vẽ nhãn ở những điểm nào
//
//  C cũng cho thấy bước chia là HỆ QUẢ của miền: không đụng gì tới mốc mà
//  Charts vẫn tự đổi từ 3 giờ sang 6 giờ khi miền rộng gấp đôi.
//
//  Nhãn cuối bị lược ở mọi bản — miền kéo tới 24 giờ nhưng nhãn dừng ở 20.
//  Garmin hiện "00 giờ" ở cả hai đầu; chưa làm được, để Basics #5.
//
//  "06 giờ" là locale Việt, không có dòng format nào.
//

import Charts
import SwiftUI

struct HeartSample: Identifiable {
  let id = UUID()
  let time: Date
  let bpm: Int
  var segment = 0
}

private let day = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 23))!

/// Trọn một ngày, để trục X luôn trải 24 giờ dù dữ liệu chỉ nằm ở vài khung giờ.
private let dayRange = day...Calendar.current.date(byAdding: .day, value: 1, to: day)!

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
      Section {
        Chart(samples) { sample in
          LineMark(
            x: .value("Giờ", sample.time),
            y: .value("BPM", sample.bpm)
          )
          .foregroundStyle(.pink)
        }
        .frame(height: 200)
      } header: {
        Text("A — LineMark thường")
      } footer: {
        Text("Sáu tiếng khuyết biến thành một đoạn thẳng dốc đều. Chart không im lặng như BarMark mà bịa ra dữ liệu chưa từng tồn tại.")
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

      Section {
        Chart(segmented) { sample in
          LineMark(
            x: .value("Giờ", sample.time),
            y: .value("BPM", sample.bpm),
            series: .value("Đoạn", sample.segment)
          )
          .foregroundStyle(.pink)
        }
        .chartXScale(domain: dayRange)
        .frame(height: 200)
      } header: {
        Text("C — chartXScale trọn 24 giờ")
      } footer: {
        Text("Chỉ khai MIỀN, không đụng tới mốc. Nhưng miền rộng ra 24 giờ khiến Charts tự đổi bước chia từ 3 giờ sang 6 giờ, ra đúng 00/06/12/18 như Apple Health.")
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
        .chartXAxis {
          AxisMarks(values: .stride(by: .hour, count: 4))
        }
        .frame(height: 200)
      } header: {
        Text("D — chỉ AxisMarks, bước 4 giờ")
      } footer: {
        Text("Bước đúng 4 giờ nhưng ĐIỂM NEO sai: mốc rơi vào 06/10/14 vì miền vẫn là 06–18 do Charts tự suy. AxisMarks chia trong miền hiện có, không tự neo về nửa đêm.")
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
        .chartXScale(domain: dayRange)
        .chartXAxis {
          AxisMarks(values: .stride(by: .hour, count: 4))
        }
        .frame(height: 200)
      } header: {
        Text("E — chartXScale + AxisMarks, như Garmin")
      } footer: {
        Text("Miền và mốc là hai việc riêng: chartXScale kéo trục trải trọn 24 giờ, AxisMarks đặt nhãn mỗi 4 giờ. Thiếu cái nào cũng không ra được trục của Garmin.")
      }
    }
  }
}

#Preview {
  NavigationStack {
    LineChartScreen()
  }
}
