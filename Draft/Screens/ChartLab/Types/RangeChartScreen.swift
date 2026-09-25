//
//  RangeChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — mọi mark từ đầu lab tới giờ nhận MỘT giá trị cho mỗi trục.
//  BarMark(x:y:) nghĩa là "ở x, một thanh từ ĐƯỜNG GỐC lên tới y". Chữ
//  đường gốc đó chưa bao giờ được viết ra, nhưng nó có thật: thanh luôn
//  mọc từ 0.
//
//  Range mark nhận HAI giá trị trên cùng một trục:
//
//    BarMark(x:yStart:yEnd:)    thanh dọc, nổi, không chạm đường gốc
//    BarMark(xStart:xEnd:y:)    thanh ngang, nổi -> Gantt
//    RectangleMark(...)         cùng hình nhưng không có logic bề rộng
//    AreaMark(x:yStart:yEnd:)   dải liên tục min–max (để dành màn #6)
//
//  CÂU HỎI của màn này: thanh thường BẮT BUỘC có 0 trong miền, không thì
//  nó bị cắt và nói dối về độ dài của chính mình. Thanh nổi thì không cần
//  0. Swift Charts có biết phân biệt hai trường hợp đó không?
//
//  Màn probe trước đây đã đo: mark nào cũng kéo trục số về chứa 0, bất kể
//  Bar, Line, Point hay Area. Nhưng đó đều là mark MỘT giá trị.
//
//  THƯỜNG THẤY Ở ĐÂU:
//    - dự báo 10 ngày trong app Thời tiết: mỗi ngày một capsule ngang từ
//      nhiệt độ thấp tới cao, cả cột chung một thang. Section B dựng lại
//    - nến chứng khoán: hai range mark cùng một x, thanh mảnh cho khoảng
//      cao–thấp (râu), thanh dày cho mở–đóng (thân). Khác nhau mỗi width:
//    - Gantt, lịch bay, ca trực: việc chạy từ mốc này tới mốc kia
//    - huyết áp: mỗi lần đo một thanh tâm trương – tâm thu
//    - khoảng tin cậy: PointMark cho giá trị đo, thanh mảnh cho sai số
//
//  Điểm chung: range mark hợp khi một hàng dữ liệu VỐN ĐÃ có hai đầu,
//  không phải khi ta gộp nhiều điểm rồi tính min/max.
//
//  ĐÃ ĐO trên simulator.
//
//  TRỤC Y VẪN CHỨA 0. Section A có dữ liệu nằm gọn trong 32–172 mà trục
//  vẫn bắt đầu từ 0. Swift Charts KHÔNG phân biệt thanh neo với thanh nổi:
//  hễ là mark số thì kéo miền về 0.
//
//  Với thanh thường thì đó là điều đúng — cắt mất đường gốc là thanh nói
//  dối về độ dài của chính nó. Với thanh nổi thì chỉ là phí: cả vùng dưới
//  giá trị thấp nhất bỏ trống, các khoảng bị ép lên trên. Nên range chart
//  gần như luôn phải tự đặt chartYScale, khác hẳn mark một giá trị.
//
//  .clipShape(Capsule()) DÙNG ĐƯỢC trên ChartContent, không chỉ trên View.
//
//  CHỒNG HAI .annotation trên cùng một mark thì cả hai đều hiện. Section B
//  dùng .leading cho số thấp và .trailing cho số cao, đúng bố cục một dòng
//  dự báo thời tiết.
//
//  AxisValueLabel(centered: true) — mốc của band scale nằm ở MÉP dải, nên
//  nhãn mặc định trôi lên trên thanh chứ không ngang hàng. Gạch đầu tiên
//  trong danh sách TODO ở Basics #5 được dùng thật.
//

import Charts
import SwiftUI

private let day = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 23))!

private struct HourRange: Identifiable {
  let id = UUID()
  let hour: Date
  let low: Int
  let high: Int
}

/// Tám giờ từ 6h, mỗi giờ một khoảng nhịp tim thấp nhất – cao nhất.
///
/// Cố ý để BỀ RỘNG các dải chênh nhau thật nhiều, vì đó mới là thứ range
/// chart kể được mà chart một giá trị không kể nổi. Một giờ ngồi yên và
/// một giờ chạy bộ có thể cùng nhịp trung bình, nhưng dải thì một cái hẹp
/// bằng ngón tay, một cái trải gần hết khung:
///
///   06  vừa ngủ dậy, chưa ra khỏi giường  — dải hẹp
///   07  ăn sáng, đi lại trong nhà
///   08  chạy bộ: khởi động rồi lên đỉnh   — rộng nhất, 64–172
///   09  vừa chạy xong, nhịp còn chưa hạ
///   10  ngồi làm việc, có lúc rơi tận 32  — thấp nhất ngày
///   11  họp căng, nhịp vọt lên rồi rơi
///   12  ăn trưa, đi bộ xuống căng tin
///   13  nghỉ trưa                          — hẹp nhất, chỉ 8 nhịp
private let hourly: [HourRange] = {
  let calendar = Calendar.current
  let values: [(low: Int, high: Int)] = [
    (52, 61), (58, 74), (64, 172), (71, 98),
    (32, 69), (60, 112), (66, 83), (55, 63),
  ]

  return values.enumerated().map { offset, value in
    HourRange(
      hour: calendar.date(byAdding: .hour, value: offset + 6, to: day)!,
      low: value.low,
      high: value.high
    )
  }
}()

private struct DayForecast: Identifiable {
  let id = UUID()
  let day: String
  let low: Int
  let high: Int
}

/// Dựng lại mục "Dự báo 10 ngày" của app Thời tiết: mỗi ngày một khoảng
/// nhiệt độ, tất cả chung một thang.
private let forecast: [DayForecast] = [
  DayForecast(day: "Hôm nay", low: 25, high: 33),
  DayForecast(day: "T6", low: 26, high: 34),
  DayForecast(day: "T7", low: 26, high: 35),
  DayForecast(day: "CN", low: 25, high: 32),
  DayForecast(day: "T2", low: 24, high: 29),
  DayForecast(day: "T3", low: 24, high: 30),
  DayForecast(day: "T4", low: 25, high: 31),
]

struct RangeChartScreen: View {
  var body: some View {
    List {
      Section {
        Chart(hourly) { item in
          BarMark(
            x: .value("Giờ", item.hour, unit: .hour),
            yStart: .value("Thấp nhất", item.low),
            yEnd: .value("Cao nhất", item.high)
          )
          .foregroundStyle(.pink)
        }
        .chartYAxis {
          AxisMarks(position: .leading)
        }
        .frame(height: 220)
      } header: {
        Text("A — BarMark(x:yStart:yEnd:) thanh nổi")
      } footer: {
        Text("Mỗi thanh mang đủ hai đầu, không chạm đường gốc nữa. Nhưng dữ liệu chỉ nằm trong 32–172 mà trục Y vẫn chạy từ 0: Swift Charts không phân biệt thanh neo với thanh nổi, hễ là mark số thì kéo miền về 0. Hậu quả là cả vùng dưới giá trị thấp nhất bỏ trống — nên range chart gần như luôn phải tự đặt chartYScale. Để ý bề rộng các dải chênh nhau bao nhiêu: giờ chạy bộ trải 108 nhịp, giờ nghỉ trưa chỉ 8. Đó mới là thứ range chart kể được.")
      }

      Section {
        Chart(forecast) { item in
          BarMark(
            xStart: .value("Thấp nhất", item.low),
            xEnd: .value("Cao nhất", item.high),
            y: .value("Ngày", item.day)
          )
          .foregroundStyle(.orange)
          .clipShape(Capsule())
          .annotation(position: .leading) {
            Text("\(item.low)°").font(.caption).foregroundStyle(.secondary)
          }
          .annotation(position: .trailing) {
            Text("\(item.high)°").font(.caption)
          }
        }
        .chartXScale(domain: 20...38)
        .chartYScale(domain: forecast.map(\.day))
        .chartYAxis {
          AxisMarks(position: .leading) {
            // Mốc của band scale nằm ở MÉP dải, nên nhãn mặc định trôi lên
            // trên thanh. centered: true kéo nhãn về tâm dải, ngang hàng
            // với thanh. Một gạch trong danh sách TODO ở Basics #5.
            AxisValueLabel(centered: true)
          }
        }
        .frame(height: 260)
      } header: {
        Text("B — BarMark(xStart:xEnd:y:) kiểu dự báo 10 ngày")
      } footer: {
        Text("Khoảng chuyển sang trục X, trục Y thành band scale tên thứ. Cả bảy thanh chung một thang 20–38° nên ngày lạnh nằm lệch trái, ngày nóng lệch phải — đó mới là thứ đáng nhìn, chứ không phải độ dài từng thanh. Thử đổi chartXScale thành 24...35 xem hình đọc khác đi thế nào.")
      }
    }
    .navigationTitle("Range")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    RangeChartScreen()
  }
}
