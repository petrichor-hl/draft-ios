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
//
//  F, G — VẼ ĐƯỜNG BẰNG CANVAS thay vì LineMark, qua chartOverlay và
//  ChartProxy. Chart chỉ còn giữ trục và miền, mark để .clear.
//
//  ĐƯỢC: màu chạy theo ĐỘ CAO trên khung. GraphicsContext.stroke với
//  .linearGradient tô shading theo TOẠ ĐỘ TUYỆT ĐỐI của canvas, không theo
//  bounding box của mark — đúng thứ LineMark không cho. Đây là kỹ thuật màn
//  Toolbox/Garmin dùng để tô màu theo vùng nhịp tim.
//
//  MẤT: interpolationMethod. GraphicsContext chỉ biết addLine và addCurve,
//  không có khái niệm nội suy. F dùng addLine nên gãy khúc; G phải tự viết
//  monotone cubic Hermite (Fritsch–Carlson) — sáu chục dòng cho thứ LineMark
//  làm bằng một modifier. Đổi lại G giữ đúng tính chất monotone: cong nhưng
//  KHÔNG vọt quá giá trị các điểm, điều kiện sống còn với nhịp tim.
//
//  BA CÁI BẪY của chartOverlay, cả ba đều trả giá mới biết:
//
//    - chartOverlay phủ TOÀN BỘ chart, còn proxy.position trả toạ độ tính từ
//      mép VÙNG VẼ. Không cộng origin của proxy.plotFrame thì đường lệch
//      đúng bề rộng trục Y.
//
//    - Canvas che touch. Phải .allowsHitTesting(false), và đặt SAU
//      GeometryReader chứ không phải sau khối if — đặt sai chỗ thì hoặc
//      không compile, hoặc (như ở Garmin) chặn luôn cả Chart và mất sạch
//      tương tác mà không có lỗi nào.
//
//    - .linearGradient của Shading nhận Gradient trần, không phải
//      LinearGradient.
//
//  Đừng đặt Chart bên trong chartPlotStyle: closure đó chạy trong layout pass
//  của Chart, tạo Chart mới bên trong là đệ quy vô hạn, tràn stack, crash.
//  Canvas thì không sao vì nó là view thường.

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

// MARK: - Section F

/// Bảy điểm, cách nhau ba giờ. Section F vẽ bằng Canvas chứ không bằng
/// LineMark, nên ít điểm để nhìn rõ từng đoạn — 360 mẫu mỗi phút thì chỉ
/// thấy một vệt liền.
private let sparse: [HeartSample] = {
  let calendar = Calendar.current
  return [62, 88, 70, 140, 120, 165, 95].enumerated().map { offset, bpm in
    HeartSample(
      time: calendar.date(byAdding: .hour, value: offset * 3 + 3, to: day)!,
      bpm: bpm
    )
  }
}()

/// Dải màu cho section F. Dùng Gradient trần vì GraphicsContext.Shading nhận
/// kiểu này chứ không phải LinearGradient.
private let lineGradient = Gradient(colors: [.blue, .green, .yellow, .orange, .red])

/// Nội suy monotone cubic Hermite (Fritsch–Carlson) — đúng thuật toán mà
/// LineMark dùng cho .monotone, nhưng Canvas thì phải tự viết:
/// GraphicsContext chỉ có addLine và addCurve, không biết interpolationMethod
/// là gì.
///
/// "Monotone" nghĩa là đường KHÔNG vọt quá giá trị của các điểm. Đó là điều
/// kiện sống còn với dữ liệu như nhịp tim hay tồn kho — một đường cong vọt
/// lên trên đỉnh là vẽ ra con số chưa từng đo được.
///
/// Ba bước:
///   1. secants — độ dốc của từng ĐOẠN thẳng nối hai điểm liền nhau
///   2. slopes  — độ dốc tại MỖI ĐIỂM, lấy trung bình hai secant kề. Nếu hai
///      secant trái dấu thì điểm đó là cực trị, độ dốc phải bằng 0, nếu không
///      đường sẽ vọt qua.
///   3. chuẩn hoá Fritsch–Carlson — ép độ dốc về trong giới hạn để đoạn cong
///      không vượt khỏi khoảng giữa hai điểm.
private func monotoneCurve(through points: [CGPoint]) -> Path {
  var path = Path()
  guard let first = points.first else { return path }
  path.move(to: first)
  guard points.count > 1 else { return path }

  let count = points.count
  var secants = [CGFloat](repeating: 0, count: count - 1)
  for index in 0..<(count - 1) {
    let dx = points[index + 1].x - points[index].x
    secants[index] = dx == 0 ? 0 : (points[index + 1].y - points[index].y) / dx
  }

  var slopes = [CGFloat](repeating: 0, count: count)
  slopes[0] = secants[0]
  slopes[count - 1] = secants[count - 2]
  for index in 1..<(count - 1) where secants[index - 1] * secants[index] > 0 {
    slopes[index] = (secants[index - 1] + secants[index]) / 2
  }

  // Đoạn phẳng thì hai đầu cũng phải phẳng, nếu không đường sẽ nhấp nhô ở
  // chỗ đáng lẽ nằm ngang.
  for index in 0..<(count - 1) where secants[index] == 0 {
    slopes[index] = 0
    slopes[index + 1] = 0
  }

  for index in 0..<(count - 1) where secants[index] != 0 {
    let a = slopes[index] / secants[index]
    let b = slopes[index + 1] / secants[index]
    let magnitude = a * a + b * b
    guard magnitude > 9 else { continue }
    let scale = 3 / magnitude.squareRoot()
    slopes[index] = scale * a * secants[index]
    slopes[index + 1] = scale * b * secants[index]
  }

  for index in 0..<(count - 1) {
    let start = points[index]
    let end = points[index + 1]
    let dx = (end.x - start.x) / 3
    path.addCurve(
      to: end,
      control1: CGPoint(x: start.x + dx, y: start.y + slopes[index] * dx),
      control2: CGPoint(x: end.x - dx, y: end.y - slopes[index + 1] * dx)
    )
  }
  return path
}

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

      Section {
        Chart {
          ForEach(sparse) { point in
            LineMark(
              x: .value("Giờ", point.time),
              y: .value("BPM", point.bpm)
            )
            .foregroundStyle(.clear)
          }
        }
        .chartXScale(domain: dayRange)
        .chartXAxis {
          AxisMarks(values: .stride(by: .hour, count: 6))
        }
        .chartOverlay { proxy in
          GeometryReader { geometry in
            // chartOverlay phủ TOÀN BỘ chart, còn proxy.position trả toạ độ
            // tính từ mép VÙNG VẼ — phải cộng origin của plotFrame, nếu không
            // đường lệch đúng bề rộng trục Y.
            if let anchor = proxy.plotFrame {
              let plot = geometry[anchor]

              Canvas { context, _ in
                var path = Path()
                var started = false

                for point in sparse {
                  guard
                    let x = proxy.position(forX: point.time),
                    let y = proxy.position(forY: point.bpm)
                  else { continue }

                  let location = CGPoint(x: plot.minX + x, y: plot.minY + y)
                  if started {
                    path.addLine(to: location)
                  } else {
                    path.move(to: location)
                    started = true
                  }
                }

                // Shading trải theo TOẠ ĐỘ TUYỆT ĐỐI của canvas, không theo
                // bounding box của path — đúng thứ LineMark không cho.
                context.stroke(
                  path,
                  with: .linearGradient(
                    lineGradient,
                    startPoint: CGPoint(x: 0, y: plot.maxY),
                    endPoint: CGPoint(x: 0, y: plot.minY)
                  ),
                  lineWidth: 3
                )
              }
            }
          }
          // Canvas che touch, tắt hit test để cử chỉ đi xuống tới Chart
          .allowsHitTesting(false)
        }
        .frame(height: 200)
      } header: {
        Text("F — chartOverlay, Canvas tự vẽ đường")
      } footer: {
        Text("Bảy điểm cho dễ nhìn. Chart chỉ giữ trục và miền, đường do Canvas vẽ qua ChartProxy bằng addLine. Được thứ LineMark không cho: màu chạy theo ĐỘ CAO trên khung, vì shading tô theo toạ độ tuyệt đối chứ không theo bounding box của mark. Đây là kỹ thuật Toolbox/Garmin dùng để tô màu theo vùng nhịp tim.")
      }

      Section {
        Chart {
          ForEach(sparse) { point in
            LineMark(
              x: .value("Giờ", point.time),
              y: .value("BPM", point.bpm)
            )
            .foregroundStyle(.clear)
          }
        }
        .chartXScale(domain: dayRange)
        .chartXAxis {
          AxisMarks(values: .stride(by: .hour, count: 6))
        }
        .chartOverlay { proxy in
          GeometryReader { geometry in
            // chartOverlay phủ TOÀN BỘ chart, còn proxy.position trả toạ độ
            // tính từ mép VÙNG VẼ — phải cộng origin của plotFrame, nếu không
            // đường lệch đúng bề rộng trục Y.
            if let anchor = proxy.plotFrame {
              let plot = geometry[anchor]

              Canvas { context, _ in
                let locations = sparse.compactMap { point -> CGPoint? in
                  guard
                    let x = proxy.position(forX: point.time),
                    let y = proxy.position(forY: point.bpm)
                  else { return nil }
                  return CGPoint(x: plot.minX + x, y: plot.minY + y)
                }

                context.stroke(
                  monotoneCurve(through: locations),
                  with: .linearGradient(
                    lineGradient,
                    startPoint: CGPoint(x: 0, y: plot.maxY),
                    endPoint: CGPoint(x: 0, y: plot.minY)
                  ),
                  lineWidth: 3
                )
              }
            }
          }
          // Canvas che touch, tắt hit test để cử chỉ đi xuống tới Chart
          .allowsHitTesting(false)
        }
        .frame(height: 200)
      } header: {
        Text("G — Canvas vẽ đường cong monotone")
      } footer: {
        Text("Y hệt F, chỉ đổi cách dựng Path. Canvas KHÔNG có interpolationMethod — GraphicsContext chỉ biết addLine và addCurve, muốn cong thì phải tự tính điểm điều khiển. Đây là monotone cubic Hermite viết tay, cùng thuật toán với .monotone ở màn 5: đường cong nhưng không vọt quá giá trị của các điểm.")
      }
    }
  }
}

#Preview {
  NavigationStack {
    LineChartScreen()
  }
}
