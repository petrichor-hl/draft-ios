//
//  ModifierLayersScreen.swift
//  Draft
//
//  ĐỀ BÀI — modifier của Swift Charts có hai tầng, đặt nhầm tầng là sai chỗ:
//    trên MARK  (bên trong Chart { })  — foregroundStyle, annotation,
//                                        interpolationMethod, lineStyle, opacity
//    trên CHART (bên ngoài Chart { })  — chartXAxis, chartLegend, chartYScale,
//                                        chartPlotStyle, chartBackground
//
//  Dựng cặp đối chứng: cùng một modifier đặt ở hai tầng, xem cái nào
//  áp lên một mark và cái nào áp lên cả biểu đồ.
//
//  ĐÃ ĐO trên simulator:
//
//  A ≡ B. foregroundStyle đặt ngoài Chart { } cho ra kết quả y hệt đặt
//  trên BarMark. Không phải vì hai tầng tương đương, mà vì nó là modifier
//  kiểu môi trường: nó đặt màu MẶC ĐỊNH, mark nào không tự khai màu thì
//  nhặt màu đó mà dùng.
//
//  C ≠ D. opacity thì không truyền xuống, nó phủ lên. Đặt trên mark thì
//  chỉ cột nhạt đi, nhãn trục và đường lưới vẫn đậm. Đặt trên chart thì
//  Charts vẽ xong cả tấm — cột, trục, nhãn, lưới — rồi mới làm mờ tất cả:
//  nhãn 10.000 / 7.500 / 0 cũng xám theo.
//
//  E. Chart nói tím, RuleMark nói đỏ → cột ra tím, đường kẻ ra đỏ. Xác
//  nhận tầng chart chỉ là mặc định; mark nào lên tiếng thì mark đó thắng.
//
//  VẬY quy tắc không phải "trong khác ngoài" mà là: modifier tầng chart
//  hoặc TRUYỀN XUỐNG làm mặc định (foregroundStyle), hoặc PHỦ LÊN kết quả
//  đã vẽ (opacity). Phải biết nó thuộc loại nào.
//
//  Cú pháp phụ: section E dùng Chart { ForEach ... } thay vì Chart(data).
//  Bắt buộc phải vậy khi muốn trộn nhiều loại mark — dạng rút gọn chỉ sinh
//  được một mark cho mỗi phần tử, còn RuleMark không thuộc phần tử nào.
//

import Charts
import SwiftUI

private let week: [DailySteps] = [
  .init(day: "T2", steps: 6200),
  .init(day: "T3", steps: 8100),
  .init(day: "T4", steps: 4300),
  .init(day: "T5", steps: 9500),
  .init(day: "T6", steps: 7200),
]

// Chia Int nên cắt phần dư — đủ dùng cho một đường tham chiếu.
private let averageSteps = week.map(\.steps).reduce(0, +) / week.count

struct ModifierLayersScreen: View {
  var body: some View {
    List {
      Section("A — foregroundStyle TRÊN MARK") {
        Chart(week) { item in
          BarMark(x: .value("Thứ", item.day), y: .value("Bước", item.steps))
            .foregroundStyle(.orange)
        }
        .frame(height: 180)
      }

      Section("B — foregroundStyle TRÊN CHART") {
        Chart(week) { item in
          BarMark(x: .value("Thứ", item.day), y: .value("Bước", item.steps))
        }
        .foregroundStyle(.orange)
        .frame(height: 180)
      }
      
      Divider()

      Section("C — opacity TRÊN MARK") {
        Chart(week) { item in
          BarMark(x: .value("Thứ", item.day), y: .value("Bước", item.steps))
            .opacity(0.25)
        }
        .frame(height: 180)
      }

      Section("D — opacity TRÊN CHART") {
        Chart(week) { item in
          BarMark(x: .value("Thứ", item.day), y: .value("Bước", item.steps))
        }
        .opacity(0.25)
        .frame(height: 180)
      }
      
      Divider()
      
      Section("E — mark thắng chart") {
        Chart {
          ForEach(week) { item in
            BarMark(x: .value("Thứ", item.day), y: .value("Bước", item.steps))
          }

          RuleMark(y: .value("Trung bình", averageSteps))
            .foregroundStyle(.red)
        }
        .foregroundStyle(.purple)
        .frame(height: 180)
      }
    }
  }
}
