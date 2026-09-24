//
//  AxisCustomScreen.swift
//  Draft
//
//  ĐỀ BÀI — giành lại quyền điều khiển TRỤC, cả X lẫn Y:
//    .chartXScale / .chartYScale(domain:)      MIỀN — trục trải từ đâu tới đâu
//    .chartXAxis / .chartYAxis + AxisMarks     MỐC — vẽ nhãn ở những điểm nào
//    AxisGridLine / AxisTick / AxisValueLabel  ba lớp trang trí của một mốc
//    AxisMarks(position:)                      trục Y nằm trái hay phải
//
//  Types #4 đã chạm chartXScale và AxisMarks(values: .stride(...)) khi dựng
//  trục thời gian. Ở đây học lại đầy đủ và có hệ thống, cả hai trục.
//
//  Đã đo ở màn 1 và 2: miền trục số mặc định LUÔN gồm 0, bất kể loại Mark
//  và bất kể trục X hay Y. Đây là màn học cách nói khác đi.
//
//  ĐÃ ĐO trên simulator, 20 mẫu từ 04 giờ tới 23 giờ.
//
//  TRỤC Y — A, B, C:
//    A  mặc định                    0 / 50 / 100 / 150 / 200, đường dồn lên
//                                   phần trên vì hai phần năm khung bỏ trống
//    B  chartYScale(55...190)       đường giãn ra chiếm trọn khung, mốc đổi
//                                   sang 75 / 100 / 125 / 150 / 175
//    C  AxisMarks(values: [...])    đúng bốn mốc mình khai, và LƯỚI NGANG ĐI
//                                   THEO chúng chứ không nằm chỗ cũ
//
//  BA LỚP TRANG TRÍ — D, E, F, G. Closure của AxisMarks THAY THẾ nội dung
//  mặc định chứ không bổ sung: khai closure là nhận trách nhiệm vẽ lại cả ba
//  lớp, bỏ sót dòng nào là mất phần đó.
//    D  AxisGridLine(stroke:)       lưới dọc từ đứt nét sang liền
//    E  bỏ AxisGridLine             mất sạch lưới dọc, nền sạch trơn
//    F  bỏ AxisTick                 KHÔNG phân biệt được với A — tick trên
//                                   iOS vẽ quá mảnh nên coi như vô hình
//    G  bỏ AxisValueLabel           mất nhãn, trục thành mấy đường kẻ vô nghĩa
//
//  H — position: .leading đưa trục Y sang trái. Nó CHỈ đổi bên, mốc và miền
//  giữ nguyên. Mặc định của Swift Charts là bên phải.
//
//  TRỤC X — I, J. Dữ liệu cố ý bắt đầu từ 04 giờ để thấy rõ:
//    A  không modifier              04 / 10 / 16 / …  neo vào đầu dữ liệu,
//                                   nhãn cuối bị rút gọn thành ba chấm
//    I  chartXScale(dayRange)       00 / 06 / 12 / 18, khoảng trống rạng sáng
//                                   hiện ra thật
//    J  thêm AxisMarks stride 4h    00 / 04 / 08 / 12 / 16 / 20
//
//  Câu chốt của cả màn: AxisMarks chọn BƯỚC, miền chọn ĐIỂM NEO. Cùng bước
//  6 giờ mà A neo vào 04 còn I neo vào 00 thì mọi nhãn đổi hết. Hai modifier
//  không thay thế nhau, cũng không cái nào bao cái nào.
//
//  Nhãn sát mép xử lý không nhất quán: ở đây bị rút gọn thành "…", còn ở
//  LineChartScreen thì biến mất hẳn. Tuỳ còn bao nhiêu chỗ trống.
//

import Charts
import SwiftUI

private let day = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 23))!

/// Trọn một ngày, dùng cho hai section về trục X.
private let dayRange = day...Calendar.current.date(byAdding: .day, value: 1, to: day)!

struct HourlyBPM: Identifiable {
  let id = UUID()
  let time: Date
  let bpm: Int
}

// Chỉ đeo đồng hồ từ 4 giờ sáng tới nửa đêm, tập nặng lúc 16–17 giờ.
// Cố ý để trống bốn tiếng đầu ngày: nhờ vậy miền Charts tự suy (04–23)
// khác với miền trọn ngày, và tác dụng của chartXScale mới nhìn thấy được.
private let hourly: [HourlyBPM] = [
  58, 62, 68, 75, 82, 78, 74, 80, 85, 79,
  76, 95, 165, 181, 120, 88, 82, 75, 68, 62,
]
.enumerated()
.map { offset, bpm in
  HourlyBPM(
    time: Calendar.current.date(byAdding: .hour, value: offset + 4, to: day)!,
    bpm: bpm
  )
}

struct AxisCustomScreen: View {
  var body: some View {
    List {
      Section("A — mặc định") {
        chart
          .frame(height: 240)
      }

      Section("B — chartYScale cắt gốc 0") {
        chart
          .chartYScale(domain: 55...190)
          .frame(height: 240)
      }

      Section("C — AxisMarks liệt kê mốc cụ thể") {
        chart
          .chartYScale(domain: 55...190)
          .chartYAxis {
            AxisMarks(values: [62, 105, 147, 190])
          }
          .frame(height: 240)
      }
      
      Divider()

      Section {
        chart
          .chartXAxis {
            AxisMarks { _ in
              AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
              AxisTick()
              AxisValueLabel()
            }
          }
          .frame(height: 240)
      } header: {
        Text("D — lưới dọc nét liền")
      } footer: {
        Text("Giống A, chỉ khai lại AxisGridLine với StrokeStyle không có dash. Không khai values: nên mốc vẫn do Charts tự chọn như A. Phải gọi đủ cả AxisTick và AxisValueLabel — closure này THAY THẾ nội dung mặc định, thiếu cái nào là mất cái đó.")
      }

      Section {
        chart
          .chartXAxis {
            AxisMarks { _ in
              AxisTick()
              AxisValueLabel()
            }
          }
          .frame(height: 240)
      } header: {
        Text("E — bỏ AxisGridLine")
      } footer: {
        Text("Mất lưới dọc, còn vạch chia và nhãn giờ. Dùng khi muốn nền sạch mà vẫn giữ lưới ngang để đọc giá trị.")
      }

      Section {
        chart
          .chartXAxis {
            AxisMarks { _ in
              AxisGridLine()
              AxisValueLabel()
            }
          }
          .frame(height: 240)
      } header: {
        Text("F — bỏ AxisTick")
      } footer: {
        Text("So với A xem có phân biệt được không. Tick trên iOS vẽ rất mảnh và ngắn nên nhiều khi vô hình.")
      }

      Section {
        chart
          .chartXAxis {
            AxisMarks { _ in
              AxisGridLine()
              AxisTick()
            }
          }
          .frame(height: 240)
      } header: {
        Text("G — bỏ AxisValueLabel")
      } footer: {
        Text("Mất sạch nhãn giờ, lưới vẫn còn. Trục trở thành mấy đường kẻ vô nghĩa — không ai đọc được biểu đồ đang nói về khoảng thời gian nào.")
      }

      Divider()
      
      Section {
        chart
          .chartYAxis {
            AxisMarks(position: .leading) {
              AxisGridLine()
              AxisTick()
              AxisValueLabel()
            }
          }
          .frame(height: 240)
      } header: {
        Text("H — trục Y sang trái")
      } footer: {
        Text("Mặc định của Swift Charts là bên phải. Đổi sang trái bằng đúng một tham số position:, không đụng gì tới miền hay mốc.")
      }
      
      Divider()

      Section {
        chart
          .chartXScale(domain: dayRange)
          .frame(height: 240)
      } header: {
        Text("I — chartXScale trục X")
      } footer: {
        Text("MIỀN của trục X. Dữ liệu chỉ từ 4 giờ nên trục tự suy ở A bắt đầu từ đó; khai dayRange thì trục trải trọn ngày và phần rạng sáng hiện ra thành khoảng trống thật.")
      }

      Section {
        chart
          .chartXScale(domain: dayRange)
          .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 4))
          }
          .frame(height: 240)
      } header: {
        Text("J — chartXScale + chartXAxis")
      } footer: {
        Text("Ghép cả hai: miền trọn 24 giờ, mốc mỗi 4 giờ. AxisMarks chọn BƯỚC, miền chọn ĐIỂM NEO — bước 4 giờ neo vào 00:00 nên ra 00/04/08/12/16/20.")
      }
    }
  }
  
  private var chart: some View {
    Chart(hourly) { item in
      LineMark(
        x: .value("Giờ", item.time),
        y: .value("BPM", item.bpm)
      )
      .foregroundStyle(.pink)
    }
  }
}
