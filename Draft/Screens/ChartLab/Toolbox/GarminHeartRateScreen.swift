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
//  ĐÃ ĐO — ba cách tô màu theo vùng nhịp tim, một cách làm CRASH.
//
//  Max HR = 220 − 31 = 189 (công thức Fox, cũng là mặc định của Garmin).
//  Sáu zone suy ra từ % của nó, biên rơi vào 95 / 113 / 132 / 151 / 170.
//
//  BƯỚC 2 — LinearGradient trên mark. SAI, và sai một cách khó thấy.
//  Gradient resolve theo BOUNDING BOX CỦA TỪNG MARK, không theo khung vẽ.
//  Đoạn sáng chỉ cao 58–72 BPM nhưng vẫn trải trọn năm màu trong đúng 14
//  nhịp đó, trong khi đáng lẽ phải xanh dương toàn bộ vì nằm dưới 95.
//
//  Ở Basics #4 section F không lộ ra vì chart đó chỉ có MỘT series, bounding
//  box gần trùng toàn dữ liệu. Thêm series thứ hai là hỏng. Vậy câu "màu bám
//  vị trí trên khung" viết ở màn đó phải sửa thành "bám vị trí trong bounding
//  box của mark".
//
//  Đã thử chuyển foregroundStyle ra TẦNG CHART: không đổi gì. Đúng với bài
//  học Basics #3 — tầng chart chỉ truyền xuống làm màu mặc định, rồi mỗi
//  mark tự resolve ShapeStyle trong hệ toạ độ của chính nó.
//
//  BƯỚC 3 — cắt đoạn theo zone, màu cứng. ĐÚNG. Mỗi lần đường cắt qua biên
//  thì chèn một điểm đúng tại biên, chèn HAI lần: một để đóng run cũ, một để
//  mở run mới. Chèn một lần thì hai đoạn hở ra.
//
//  Phải lặp vì một bước có thể vượt nhiều biên — nhịp nhảy 100 lên 180 trong
//  một phút là cắt qua bốn biên.
//
//  splitSegments vẫn giữ nguyên tác dụng: gặp khoảng trống dữ liệu thì mở
//  run mới mà KHÔNG chèn điểm biên, nên đường vẫn đứt đúng chỗ tháo đồng hồ.
//  Hai cơ chế cắt đoạn chồng lên nhau không xung đột.
//
//  Đổi lại màu chuyển KHỐI chứ không mượt như Garmin.
//
//  CÁCH MASK LÀM CRASH — đừng thử lại. Ý tưởng: phủ gradient lên vùng vẽ rồi
//  mask bằng một Chart thứ hai ẩn trục, đặt trong .chartPlotStyle { $0.overlay }.
//  Kết quả: EXC_BAD_ACCESS ở Stack Guard region, stack trace toàn khung Charts
//  lặp lại — tràn stack do đệ quy vô hạn.
//
//  Lý do: closure của chartPlotStyle chạy TRONG layout pass của Chart. Tạo
//  một Chart mới bên trong nó thì Chart đó lại chạy layout, lại gọi closure,
//  không có điểm dừng.
//
//  BẪY BUILD gặp hai lần trong lúc làm màn này: xcodebuild báo BUILD SUCCEEDED
//  nhưng không biên dịch lại, binary giữ nguyên bản cũ nên sửa code mà màn hình
//  không đổi. Kiểm tra bằng cách so mtime của binary với file nguồn; chữa bằng
//  xcodebuild clean.
//
//  CÒN LẠI để giống ảnh Garmin: màu mượt thay vì khối, nền tối, dãy chấm tròn
//  trên trục X (chờ mục AxisValueLabel + ViewBuilder trong TODO của Basics #5).
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

// MARK: - Vùng nhịp tim

private let age: Double = 31

/// Công thức Fox, cũng là mặc định của Garmin. Mọi biên zone suy ra từ đây
/// nên đổi tuổi là cả bảng tự cập nhật.
private let maxHR = 220 - age

/// Miền trục Y cố định. zoneGradient tính vị trí màu theo ĐÚNG miền này,
/// nên hai thứ phải luôn đi cùng nhau — sửa một chỗ quên chỗ kia thì màu
/// lệch mà không có lỗi biên dịch nào.
private let hrDomain: ClosedRange<Double> = 55...190

private struct HRZone {
  let name: String
  let lower: Double
  let color: Color
}

private let zones: [HRZone] = [
  .init(name: "Nghỉ ngơi", lower: 0, color: .blue),
  .init(name: "Vùng 1", lower: maxHR * 0.50, color: .blue),
  .init(name: "Vùng 2", lower: maxHR * 0.60, color: .green),
  .init(name: "Vùng 3", lower: maxHR * 0.70, color: .yellow),
  .init(name: "Vùng 4", lower: maxHR * 0.80, color: .orange),
  .init(name: "Vùng 5", lower: maxHR * 0.90, color: .red),
]

/// Vị trí 0…1 của một giá trị BPM trên khung vẽ, theo hrDomain.
/// startPoint: .bottom nên 0 là đáy, trùng chiều trục Y.
private func location(of bpm: Double) -> Double {
  let span = hrDomain.upperBound - hrDomain.lowerBound
  return min(max((bpm - hrDomain.lowerBound) / span, 0), 1)
}

/// Mỗi màu đặt ở TÂM zone của nó, để gradient nội suy mượt phần giữa —
/// giống Garmin, không nhảy khối tại biên.
private let zoneGradient = LinearGradient(
  stops: zones.indices.map { index in
    let lower = max(zones[index].lower, hrDomain.lowerBound)
    let upper = index + 1 < zones.count
      ? zones[index + 1].lower
      : hrDomain.upperBound
    return Gradient.Stop(
      color: zones[index].color,
      location: location(of: (lower + upper) / 2)
    )
  },
  startPoint: .bottom,
  endPoint: .top
)

/// Biên các zone, bỏ mốc 0 của vùng nghỉ ngơi.
private let zoneBoundaries = zones.dropFirst().map { $0.lower.rounded() }

// MARK: - Cắt đoạn theo zone

/// Một điểm đã biết mình thuộc zone nào và thuộc đoạn liên tục nào.
/// `runID` là định danh của một chuỗi điểm liền nhau CÙNG zone — mỗi run
/// thành một series riêng để tô được màu cứng của zone đó.
private struct ZonedPoint: Identifiable {
  let id = UUID()
  let time: Date
  let bpm: Double
  let zoneIndex: Int
  let runID: Int
}

/// Zone cao nhất mà `bpm` còn vượt được biên dưới.
private func zoneIndex(for bpm: Double) -> Int {
  var index = 0
  for (offset, zone) in zones.enumerated() where bpm >= zone.lower {
    index = offset
  }
  return index
}

/// Duyệt theo thời gian, mỗi lần đường cắt qua một biên zone thì CHÈN một
/// điểm đúng tại biên đó — chèn hai lần, một để đóng run cũ, một để mở run
/// mới. Nhờ vậy hai đoạn khớp nhau, không có khe hở.
///
/// Một bước nhảy lớn có thể vượt nhiều biên cùng lúc (100 → 180 qua bốn
/// biên), nên phải lặp chứ không chỉ xử lý một biên.
private func zoned(_ samples: [HeartSample]) -> [ZonedPoint] {
  var result: [ZonedPoint] = []
  var runID = 0

  for (offset, sample) in samples.enumerated() {
    let bpm = Double(sample.bpm)
    let currentZone = zoneIndex(for: bpm)

    if offset > 0 {
      let previous = samples[offset - 1]
      let previousBPM = Double(previous.bpm)
      let previousZone = zoneIndex(for: previousBPM)

      if previous.segment != sample.segment {
        // Khoảng trống dữ liệu: mở run mới, KHÔNG nối qua
        runID += 1
      } else if previousZone != currentZone {
        let step = currentZone > previousZone ? 1 : -1
        var zone = previousZone

        while zone != currentZone {
          let boundary = step > 0 ? zones[zone + 1].lower : zones[zone].lower
          let ratio = (boundary - previousBPM) / (bpm - previousBPM)
          let crossing = previous.time.addingTimeInterval(
            sample.time.timeIntervalSince(previous.time) * ratio
          )

          result.append(
            ZonedPoint(time: crossing, bpm: boundary, zoneIndex: zone, runID: runID)
          )
          runID += 1
          result.append(
            ZonedPoint(time: crossing, bpm: boundary, zoneIndex: zone + step, runID: runID)
          )
          zone += step
        }
      }
    }

    result.append(
      ZonedPoint(time: sample.time, bpm: bpm, zoneIndex: currentZone, runID: runID)
    )
  }
  return result
}

private let zonedPoints = zoned(segmented)

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

      Section {
        Chart {
          ForEach(segmented) { sample in
            LineMark(
              x: .value("Giờ", sample.time),
              y: .value("BPM", Double(sample.bpm)),
              series: .value("Đoạn", sample.segment)
            )
            .foregroundStyle(zoneGradient)
          }
        }
        .chartXScale(domain: dayRange)
        .chartYScale(domain: hrDomain)
        .chartXAxis {
          AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
            AxisValueLabel()
          }
        }
        .chartYAxis {
          AxisMarks(position: .leading, values: zoneBoundaries) { _ in
            AxisGridLine()
            AxisValueLabel(horizontalSpacing: 12)
          }
        }
        .frame(height: 240)
      } header: {
        Text("Bước 2 — màu theo vùng nhịp tim")
      } footer: {
        Text("Max HR = 220 − 31 = 189. Sáu zone suy ra từ % của nó, mỗi màu đặt ở TÂM zone để gradient nội suy mượt. Trục Y khoá ở 55…190 và mốc đặt đúng biên zone: 95 / 113 / 132 / 151 / 170.")
      }

      Section {
        Chart {
          ForEach(zonedPoints) { point in
            LineMark(
              x: .value("Giờ", point.time),
              y: .value("BPM", point.bpm),
              series: .value("Đoạn", point.runID)
            )
            .foregroundStyle(zones[point.zoneIndex].color)
          }

          RuleMark(x: .value("Mốc", day))
            .foregroundStyle(.gray.opacity(0.5))
            .lineStyle(StrokeStyle(lineWidth: 1))
        }
        .chartXScale(domain: dayRange)
        .chartYScale(domain: hrDomain)
        .chartXAxis {
          AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
            AxisValueLabel()
          }
        }
        .chartYAxis {
          AxisMarks(position: .leading, values: zoneBoundaries) { _ in
            AxisGridLine()
            AxisValueLabel(horizontalSpacing: 12)
          }
        }
        .frame(height: 240)
      } header: {
        Text("Bước 3 — cắt đoạn theo zone, màu cứng")
      } footer: {
        Text("Màu bám GIÁ TRỊ tuyệt đối, không còn phụ thuộc bounding box. Đoạn sáng phải xanh dương toàn bộ vì nằm trọn dưới 95. Đổi lại màu chuyển khối chứ không mượt, và số series tăng vọt vì mỗi lần cắt biên là một run mới.")
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
