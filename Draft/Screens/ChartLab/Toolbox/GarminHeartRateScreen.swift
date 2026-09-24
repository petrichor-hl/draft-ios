//
//  GarminHeartRateScreen.swift
//  Draft
//
//  Dựng lại chart nhịp tim của Garmin Connect, màn "Dòng thời gian hàng ngày".
//  Khác Apple Health: Garmin vẽ ĐƯỜNG liền từ hàng nghìn mẫu, Apple vẽ từng
//  mẫu thành một mark rời.
//
//  VÙNG NHỊP TIM — Max HR = 220 − 31 = 189 theo công thức Fox. Sáu zone suy ra
//  từ % của nó, biên rơi vào 95 / 113 / 132 / 151 / 170 và dùng luôn làm mốc
//  trục Y, nên nhìn đường lưới là kiểm chứng được màu đổi đúng chỗ hay chưa.
//
//  BỐN CÁCH TÔ MÀU, một cái sai:
//
//    1  một màu                     đối chứng
//    2  LinearGradient trên mark    SAI — bám bounding box của mark
//    3  cắt đoạn theo zone          đúng, màu khối
//    4  Canvas tự vẽ                đúng, màu mượt
//
//  VÌ SAO CÁCH 2 SAI. Gradient resolve theo bounding box CỦA TỪNG MARK chứ
//  không theo khung vẽ. Đoạn sáng chỉ cao 58–72 BPM mà vẫn trải trọn năm màu
//  trong đúng 14 nhịp đó. Ở Basics #4 section F không lộ ra vì chart đó chỉ có
//  một series, bounding box gần trùng toàn dữ liệu.
//
//  Vậy câu "màu bám vị trí trên khung" viết ở Basics #4 phải sửa thành "bám vị
//  trí trong bounding box của mark".
//
//  Chuyển foregroundStyle ra tầng chart không cứu được — đúng bài học Basics
//  #3: tầng chart chỉ truyền xuống làm mặc định, rồi mỗi mark tự resolve
//  ShapeStyle trong hệ toạ độ của chính nó.
//
//  CÁCH 3 — mỗi lần đường cắt biên thì chèn HAI điểm cùng toạ độ: một đóng run
//  cũ, một mở run mới. Chèn một lần thì hai đoạn hở ra. Phải lặp vì một bước
//  có thể vượt nhiều biên (100 lên 180 là bốn biên). splitSegments vẫn giữ
//  nguyên tác dụng — hai cơ chế cắt đoạn chồng lên nhau không xung đột.
//
//  CÁCH 4 — GraphicsContext.stroke với .linearGradient tô shading theo TOẠ ĐỘ
//  TUYỆT ĐỐI, không theo bounding box của path. Đúng thứ LineMark không cho.
//  Charts vẫn lo trục, lưới và miền; chỉ riêng đường là tự vẽ.
//
//  Bẫy của cách 4: chartOverlay phủ TOÀN BỘ chart, còn proxy.position trả toạ
//  độ tính từ mép VÙNG VẼ. Trục Y bên trái chiếm chỗ nên đường lệch đúng bề
//  rộng đó — phải cộng origin của proxy.plotFrame.
//
//  CÁCH 4 GIỮ ĐƯỢC chartXSelection, với một điều kiện: Canvas che touch nên
//  overlay phải .allowsHitTesting(false). Vậy nó thắng cả ba cách còn lại về
//  mọi mặt trừ độ phức tạp — màu mượt, bám giá trị, và vẫn chọn được. Riêng
//  VoiceOver theo điểm thì vẫn mất, vì đường không còn là mark.
//
//  VỊ TRÍ CỦA .allowsHitTesting(false) QUAN TRỌNG. Nó không có khái niệm "chỉ
//  tắt cho lớp phủ": đặt SAU dấu đóng của chartOverlay là chặn cả cây view bên
//  dưới, kể cả chính Chart, và chart điếc hoàn toàn với mọi cử chỉ. Phải đặt
//  BÊN TRONG closure, lên riêng GeometryReader. Sai một cấp thụt lề là mất
//  trắng tương tác mà không có lỗi biên dịch nào.
//
//  BA LẦN THỬ SELECTION ĐỀU TRƯỢT vì cùng một lý do: chạm nhanh thay vì CHẠM
//  GIỮ. Đó là sai lầm về CÁCH ĐO, không phải về code, và nó suýt khiến một kết
//  luận sai được ghi vào file. Chuỗi loại biến về sau mới gỡ ra được:
//    chart 6  LineMark thường          → chạy, nhưng phải chạm giữ
//    chart 5  LineMark .clear, no Canvas → vẫn chạy, nên .clear vô can
//    chart 4  có Canvas                → chạy nốt, sau khi sửa allowsHitTesting
//
//  BA ĐIỀU VỀ chartXSelection, đo trên bản LineMark thường (section đó đã xoá
//  sau khi lấy được kết luận):
//
//    - Phải CHẠM GIỮ, chạm nhanh không ăn. Giống hệt Apple Health, và có lý do:
//      chart nằm trong List nên chạm-rồi-kéo vốn thuộc về cuộn trang, giữ một
//      nhịp mới chuyển thành scrubbing.
//    - Binding trả về giá trị trên TRỤC X (một Date), không phải điểm dữ liệu,
//      nên phải tự tìm mẫu gần nhất.
//    - Nhãn dùng .regularMaterial cho ra nền tối, mà Text để màu chữ mặc định
//      thì không đọc được. Phải tự tô màu đặc và chữ tương phản.
//
//  Dùng overflowResolution: .init(x: .fit, y: .disabled) để nhãn không tràn
//  khỏi khung khi chọn gần hai mép.
//
//  CÁCH MASK LÀM CRASH — đừng thử lại. Chart đặt trong closure của
//  chartPlotStyle gây đệ quy vô hạn: closure chạy trong layout pass của Chart,
//  mà bên trong lại tạo Chart mới, cái đó lại chạy layout. Kết quả
//  EXC_BAD_ACCESS ở Stack Guard region, stack trace toàn khung Charts lặp lại.
//  Canvas thì không sao vì nó là view thường, không có layout pass lồng nhau.
//
//  BẪY BUILD gặp hai lần trong lúc làm màn này: xcodebuild báo BUILD SUCCEEDED
//  nhưng không biên dịch lại, binary giữ bản cũ nên sửa code mà màn hình không
//  đổi. Phát hiện bằng cách so mtime của binary với file nguồn; chữa bằng
//  xcodebuild clean.
//
//  CHART 5 — giữ chartYAxis nhưng bỏ values: zoneBoundaries. Màu không đổi,
//  xác nhận MỐC và MIỀN là hai việc rời nhau: gradient chỉ phụ thuộc miền.
//  Nhưng mốc về mặc định 75/100/125/150/175 nên mất khả năng tự kiểm chứng —
//  ở chart 4, lưới nằm đúng biên zone nên nhìn là biết màu đổi có đúng chỗ.
//  Giữ AxisMarks(values:) không phải để đẹp mà để mốc trục và ngưỡng màu nói
//  cùng một ngôn ngữ.
//
//  CÒN LẠI để giống ảnh Garmin: nền tối, và dãy chấm tròn trên trục X — chờ
//  mục AxisValueLabel + ViewBuilder trong TODO của Basics #5.
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

/// Miền trục Y CỐ ĐỊNH, không co theo dữ liệu từng ngày. Hai lý do:
///
///   - zoneStops tính vị trí màu theo ĐÚNG miền này. Miền co theo dữ liệu thì
///     cùng một nhịp tim sẽ ra màu khác nhau giữa các ngày, và màu mất hết ý
///     nghĩa so sánh. Garmin cũng cố định: ngày dữ liệu 71–120 vẫn hiện trục
///     62…190 y như ngày có đỉnh 181.
///
///   - Chặn dưới 40 nằm dưới ngưỡng của gần như mọi người trưởng thành lúc
///     ngủ, nên không bao giờ cắt mất dữ liệu. Đổi lại vùng 40–58 gần như
///     luôn trống. Bản trước để 55 và suýt hỏng: công thức sinh mẫu buổi sáng
///     có đáy lý thuyết đúng bằng 55, chỉ cần tăng nhiễu là đường bị cắt phẳng
///     ở đáy mà không có cảnh báo nào.
///
/// Sửa miền mà quên zoneStops thì màu lệch, KHÔNG có lỗi biên dịch nào.
private let hrDomain: ClosedRange<Double> = 40...190

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
private let zoneStops: [Gradient.Stop] = zones.indices.map { index in
  let lower = max(zones[index].lower, hrDomain.lowerBound)
  let upper = index + 1 < zones.count
  ? zones[index + 1].lower
  : hrDomain.upperBound
  return Gradient.Stop(
    color: zones[index].color,
    location: location(of: (lower + upper) / 2)
  )
}

/// Bản LinearGradient, dùng cho foregroundStyle của mark.
private let zoneGradient = LinearGradient(
  stops: zoneStops,
  startPoint: .bottom,
  endPoint: .top
)

/// Bản Gradient trần, dùng cho GraphicsContext.Shading trong Canvas.
private let zoneGradientValue = Gradient(stops: zoneStops)

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
  /// chartXSelection trả về giá trị trên TRỤC X, không phải điểm dữ liệu.
  @State private var selectedTime: Date?
  
  /// Nên phải tự tìm mẫu gần nhất với mốc thời gian đã chọn.
  private var selectedSample: HeartSample? {
    guard let selectedTime else { return nil }
    return segmented.min {
      abs($0.time.timeIntervalSince(selectedTime))
      < abs($1.time.timeIntervalSince(selectedTime))
    }
  }
  
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
      } header: {
        Text("1 — LineMark một màu, tách series ở khoảng trống")
      } footer: {
        Text("Đường liền mạch và đứt đúng chỗ tháo đồng hồ. Trục X trải trọn 24 giờ bước 6 và không còn lưới dọc; trục Y bên trái. Màu chưa nói gì về cường độ.")
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
        Text("2 — LinearGradient đặt thẳng lên mark")
      } footer: {
        Text("SAI. Gradient trải theo bounding box của TỪNG mark: đoạn sáng cao vỏn vẹn 58–72 BPM mà vẫn đủ năm màu, đáng lẽ xanh dương toàn bộ vì nằm dưới 95. Chuyển foregroundStyle ra tầng chart cũng không đổi gì.")
      }
      
      Section {
        Chart(zonedPoints) { point in
          
          LineMark(
            x: .value("Giờ", point.time),
            y: .value("BPM", point.bpm),
            series: .value("Đoạn", point.runID)
          )
          .foregroundStyle(zones[point.zoneIndex].color)
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
        Text("3 — cắt đoạn tại biên zone, mỗi đoạn một màu cứng")
      } footer: {
        Text("ĐÚNG. Màu bám giá trị tuyệt đối, đổi đúng tại đường lưới 113 / 132 / 151 / 170, và đoạn sáng xanh dương toàn bộ. Đổi lại màu chuyển khối, số series tăng theo số lần cắt biên.")
      }
      
      Section {
        Chart {
          ForEach(segmented) { sample in
            LineMark(
              x: .value("Giờ", sample.time),
              y: .value("BPM", Double(sample.bpm)),
              series: .value("Đoạn", sample.segment)
            )
            .foregroundStyle(.clear)
          }
          
          if let selectedSample {
            RuleMark(x: .value("Chọn", selectedSample.time))
              .foregroundStyle(.secondary)
              .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
              .annotation(
                position: .top,
                overflowResolution: .init(x: .fit, y: .disabled)
              ) {
                Text("\(selectedSample.bpm) BPM")
                  .font(.caption2.bold())
                  .foregroundStyle(.white)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(.pink, in: Capsule())
                  .fixedSize()
              }
          }
        }
        .chartXSelection(value: $selectedTime)
        .chartXScale(domain: dayRange)
        .chartXAxis {
          AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
            AxisValueLabel()
          }
        }
        .chartYScale(domain: hrDomain)
        .chartYAxis {
          AxisMarks(position: .leading, values: zoneBoundaries) { _ in
            AxisGridLine()
            AxisValueLabel(horizontalSpacing: 12)
          }
        }
        .chartOverlay { proxy in
          GeometryReader { geometry in
            // chartOverlay phủ TOÀN BỘ chart, còn proxy.position trả toạ độ
            // tính từ mép VÙNG VẼ. Trục Y bên trái chiếm chỗ nên phải bù
            // bằng origin của plotFrame, nếu không đường lệch sang trái.
            if let anchor = proxy.plotFrame {
              let plot = geometry[anchor]
              
              Canvas { context, _ in
                // Mỗi segment một path riêng, để khoảng trống dữ liệu vẫn đứt
                let bySegment = Dictionary(grouping: segmented, by: \.segment)
                
                for key in bySegment.keys.sorted() {
                  guard let points = bySegment[key] else { continue }
                  var path = Path()
                  var started = false
                  
                  for point in points.sorted(by: { $0.time < $1.time }) {
                    guard
                      let x = proxy.position(forX: point.time),
                      let y = proxy.position(forY: Double(point.bpm))
                        else { continue }
                    
                    let location = CGPoint(x: plot.minX + x, y: plot.minY + y)
                    if started {
                      path.addLine(to: location)
                    } else {
                      path.move(to: location)
                      started = true
                    }
                  }
                  
                  // Shading trải theo TOẠ ĐỘ TUYỆT ĐỐI, không theo bounding
                  // box của path — đúng thứ LineMark không cho. Hai đầu lấy
                  // theo plot area để khớp với miền trục Y.
                  context.stroke(
                    path,
                    with: .linearGradient(
                      zoneGradientValue,
                      startPoint: CGPoint(x: 0, y: plot.maxY),
                      endPoint: CGPoint(x: 0, y: plot.minY)
                    ),
                    lineWidth: 2
                  )
                }
              }
            }
          }
          .allowsHitTesting(false)
        }
        .frame(height: 240)
        .padding(.top, 40)
      } header: {
        Text("4 — Canvas tự vẽ, cộng chartXSelection")
      } footer: {
        Text("ĐÚNG và MƯỢT. Shading tô theo toạ độ tuyệt đối nên màu vừa bám giá trị vừa nội suy liên tục. Phải cộng origin của plotFrame vì chartOverlay phủ cả trục trong khi proxy.position tính từ mép vùng vẽ. Và VẪN CHỌN ĐƯỢC. Canvas che touch, nên overlay phải .allowsHitTesting(false) — đặt BÊN TRONG closure của chartOverlay, lên riêng GeometryReader. Đặt sau dấu đóng là chặn luôn cả Chart, chart điếc hoàn toàn.")
      }
      
      Section {
        Chart {
          ForEach(segmented) { sample in
            LineMark(
              x: .value("Giờ", sample.time),
              y: .value("BPM", Double(sample.bpm)),
              series: .value("Đoạn", sample.segment)
            )
            .foregroundStyle(.clear)
          }
          
          if let selectedSample {
            RuleMark(x: .value("Chọn", selectedSample.time))
              .foregroundStyle(.secondary)
              .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
              .annotation(
                position: .top,
                overflowResolution: .init(x: .fit, y: .disabled)
              ) {
                Text("\(selectedSample.bpm) BPM")
                  .font(.caption2.bold())
                  .foregroundStyle(.white)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(.pink, in: Capsule())
                  .fixedSize()
              }
          }
        }
        .chartXSelection(value: $selectedTime)
        .chartXScale(domain: dayRange)
        .chartXAxis {
          AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
            AxisValueLabel()
          }
        }
        .chartYScale(domain: hrDomain)
        .chartYAxis {
          AxisMarks(position: .leading)
        }
        .chartOverlay { proxy in
          GeometryReader { geometry in
            // chartOverlay phủ TOÀN BỘ chart, còn proxy.position trả toạ độ
            // tính từ mép VÙNG VẼ. Trục Y bên trái chiếm chỗ nên phải bù
            // bằng origin của plotFrame, nếu không đường lệch sang trái.
            if let anchor = proxy.plotFrame {
              let plot = geometry[anchor]
              
              Canvas { context, _ in
                // Mỗi segment một path riêng, để khoảng trống dữ liệu vẫn đứt
                let bySegment = Dictionary(grouping: segmented, by: \.segment)
                
                for key in bySegment.keys.sorted() {
                  guard let points = bySegment[key] else { continue }
                  var path = Path()
                  var started = false
                  
                  for point in points.sorted(by: { $0.time < $1.time }) {
                    guard
                      let x = proxy.position(forX: point.time),
                      let y = proxy.position(forY: Double(point.bpm))
                        else { continue }
                    
                    let location = CGPoint(x: plot.minX + x, y: plot.minY + y)
                    if started {
                      path.addLine(to: location)
                    } else {
                      path.move(to: location)
                      started = true
                    }
                  }
                  
                  // Shading trải theo TOẠ ĐỘ TUYỆT ĐỐI, không theo bounding
                  // box của path — đúng thứ LineMark không cho. Hai đầu lấy
                  // theo plot area để khớp với miền trục Y.
                  context.stroke(
                    path,
                    with: .linearGradient(
                      zoneGradientValue,
                      startPoint: CGPoint(x: 0, y: plot.maxY),
                      endPoint: CGPoint(x: 0, y: plot.minY)
                    ),
                    lineWidth: 2
                  )
                }
              }
            }
          }
          .allowsTightening(false)
        }
        .frame(height: 240)
        .padding(.top, 40)
      } header: {
        Text("5 — LineMark trong suốt, tắt Canvas, giữ chartXSelection")
      } footer: {
        Text("Chart trống trơn vì không còn gì để nhìn, nhưng CHẠM GIỮ vẫn hiện nhãn BPM. Nghĩa là .clear KHÔNG chặn selection — Charts vẫn coi mark vô hình là thứ để nhắm tới. Nhờ vậy loại được một nghi phạm, và chỉ đúng thủ phạm ở chart 4: Canvas nằm đè lên nuốt mất touch.")
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
