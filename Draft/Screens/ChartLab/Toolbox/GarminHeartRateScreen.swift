//
//  GarminHeartRateScreen.swift
//  Draft
//
//  ĐỀ BÀI — dựng lại chart nhịp tim của Garmin Connect, màn "Dòng thời
//  gian hàng ngày". Khác hẳn Apple Health: Garmin vẽ ĐƯỜNG liền từ hàng
//  nghìn mẫu, Apple vẽ từng mẫu thành mark rời.
//
//  Đặc điểm đọc từ ảnh chụp:
//
//  1. LineMark dày đặc, răng cưa — mỗi mẫu một điểm, không gộp bucket.
//
//  2. Màu chạy theo GIÁ TRỊ Y: xanh dương ở vùng thấp, lên lục, vàng, cam,
//     rồi đỏ ở đỉnh. Đã đo ở Basics #4: foregroundStyle(by:) KHÔNG dùng
//     được trên LineMark — nó sinh scale, Charts lấy scale đó làm chiều
//     phân nhóm và đường vỡ thành các vạch ngang. Phải đưa thẳng một
//     LinearGradient dọc vào foregroundStyle.
//
//  3. Trục Y KHÔNG có số 0. Mốc 62 / 105 / 147 / 190, cách đều nhau 42–43
//     đơn vị. Cần chartYScale(domain:) và AxisMarks(values: [...]) —
//     Basics #5.
//     CHƯA ĐO: 62 và 190 lấy từ đâu — min/max của ngày làm tròn, hay biên
//     zone cố định theo tuổi?
//
//  4. Đường ĐỨT ĐOẠN ở những giờ không đeo đồng hồ. Dùng splitSegments +
//     tham số series: — Types #4.
//
//  5. Trục X là dãy chấm tròn thay cho vạch chia, nhãn mỗi 4 giờ. Dùng
//     AxisMarks với AxisValueLabel tự vẽ.
//
//  6. Nền tối, không có lưới dọc, lưới ngang mảnh.
//
//  BƯỚC HIỆN TẠI — chép chart E từ LineChartScreen sang, đổi bước chia
//  trục X sang 6 giờ và bỏ lưới dọc. Chưa có màu theo giá trị, chưa cắt
//  gốc trục Y, chưa nền tối.
//

import Charts
import SwiftUI

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

struct GarminHeartRateScreen: View {
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
        }
        .chartXScale(domain: dayRange)
        .chartXAxis {
          AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
            AxisValueLabel()
          }
        }
        .chartYAxis {
          AxisMarks(position: .leading) { _ in
            AxisGridLine()
            AxisValueLabel(horizontalSpacing: 12)
          }
        }
        .frame(height: 240)
      }
    }
    .navigationTitle("Garmin — Nhịp tim")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    GarminHeartRateScreen()
  }
}
