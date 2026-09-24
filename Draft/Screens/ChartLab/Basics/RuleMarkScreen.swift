//
//  RuleMarkScreen.swift
//  Draft
//
//  ĐỀ BÀI — RuleMark vẽ một ĐƯỜNG tham chiếu cho cả biểu đồ: trung bình,
//  ngưỡng, mốc thời gian đáng chú ý. Như RectangleMark ở màn trước, nó
//  không thuộc về điểm dữ liệu nào nên phải viết ngoài ForEach.
//
//    RuleMark(y:)               đường ngang suốt chiều rộng
//    RuleMark(x:)               đường dọc suốt chiều cao
//    RuleMark(xStart:xEnd:y:)   đoạn ngang chỉ trong một khoảng
//    RuleMark(x:yStart:yEnd:)   đoạn dọc chỉ trong một khoảng
//
//  Kèm .lineStyle(StrokeStyle(dash:)) cho nét đứt và .annotation để gắn
//  nhãn cho chính đường đó.
//
//  CẦN ĐO:
//    1. RuleMark có ăn vào domain không? RectangleMark thì CÓ — đo ở màn
//       Vùng nền, vùng 15.000–20.000 kéo trục lên 20.000.
//    2. RuleMark(x:) trên band scale rơi vào TÂM dải hay MÉP dải? Vùng nền
//       đã cho thấy .value("Từ", "T3") trỏ vào tâm.
//    3. Gắn được annotation lên RuleMark không, và nhãn neo vào đâu?
//

import Charts
import SwiftUI

private let day = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 23))!

private let dayRange = day...Calendar.current.date(byAdding: .day, value: 1, to: day)!

/// Duyệt theo thứ tự thời gian, gặp khoảng trống lớn hơn `gap` thì mở đoạn mới.
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
  let morning = run(from: 6 * 60, to: 9 * 60, noise: 3) { progress in
    64 + 6 * sin(progress * 8 * .pi)
  }

  let evening = run(from: 15 * 60, to: 18 * 60, noise: 5) { progress in
    80 + 95 * sin(progress * .pi) + 14 * sin(progress * 14 * .pi)
  }

  return morning + evening
}()

private let segmented = splitSegments(samples, gap: 5 * 60)

struct RuleMarkScreen: View {
  var body: some View {
    List {
      Section {
        Chart {
          ForEach(segmented) { sample in
            LineMark(
              x: .value("Giờ", sample.time),
              y: .value("BPM", sample.bpm),
              series: .value("Đoạn", sample.segment)
            )
            .foregroundStyle(.pink)
          }

          RuleMark(x: .value("Mốc", day))
            .foregroundStyle(.gray.opacity(0.5))
            .lineStyle(StrokeStyle(lineWidth: 1))
        }
        .chartXScale(domain: dayRange)
        .chartXAxis {
          AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
            AxisValueLabel()
          }
        }
        .chartYAxis {
          AxisMarks(position: .leading)
        }
        .frame(height: 240)
      } header: {
        Text("A — RuleMark(x:) đánh dấu một mốc")
      } footer: {
        Text("Đường dọc xám ở 00 giờ.")
      }
    }
    .navigationTitle("RuleMark")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    RuleMarkScreen()
  }
}
