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
//  ĐÃ ĐO trên simulator.
//
//  RuleMark ĂN VÀO DOMAIN, y như RectangleMark. Một ngưỡng đặt ở 400 trong
//  khi dữ liệu cao nhất 190 kéo trục lên 0–400 và nén đường nhịp tim xuống
//  nửa dưới khung. Hệ quả: đặt ngưỡng cao — "nhịp tối đa 220", "hạn mức 10
//  triệu" — là tự bóp bẹp biểu đồ. Muốn tránh thì khoá chartYScale trước,
//  khi đó RuleMark ngoài miền bị cắt thay vì kéo giãn trục.
//
//  Hai mark này cư xử giống nhau vì cùng một họ: mark KHÔNG thuộc điểm dữ
//  liệu nào, nhưng vẫn được tính vào miền như một điểm thật.
//
//  ANNOTATION GẮN ĐƯỢC, nhưng `position` mang HAI NGHĨA tuỳ hướng của mark:
//
//    RuleMark(y:) — đường NGANG, không có đầu trên hay đầu dưới. position chỉ
//      quyết định nhãn nằm TRÊN hay DƯỚI đường; vị trí theo chiều ngang phải
//      nói riêng bằng alignment (.leading dồn về mép trái).
//
//    RuleMark(x:) — đường DỌC, có đầu trên thật. position: .top neo đúng vào
//      đó, không cần alignment. Toolbox/Garmin dùng đúng cách này cho nhãn
//      BPM khi chạm giữ.
//
//  Annotation của RuleMark KHÔNG nới domain, khác annotation của BarMark ở
//  Basics #6 — có lẽ vì nhãn nằm đè lên vùng vẽ chứ không đòi chỗ bên ngoài.
//
//  BAND SCALE: .value("Mốc", "T4") trỏ vào TÂM dải, không phải mép — đường
//  cắt đôi cột T4. Giống RectangleMark ở màn Vùng nền. Cột, đường và nhãn
//  trục đều quy về cùng một điểm. (Section đo việc này đã xoá sau khi có kết
//  luận; ba section còn lại đều dùng trục thời gian.)
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

/// Chia Int nên cắt phần dư — đủ dùng cho một đường tham chiếu.
private let averageBPM = samples.map(\.bpm).reduce(0, +) / samples.count

/// Mốc 12 giờ, dùng cho RuleMark dọc ở section E.
private let noon = Calendar.current.date(byAdding: .hour, value: 12, to: day)!


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

      Section {
        Chart {
          ForEach(segmented) { sample in
            LineMark(
              x: .value("Giờ", sample.time),
              y: .value("BPM", sample.bpm),
              series: .value("Đoạn", sample.segment)
            )
            .foregroundStyle(.pink.opacity(0.5))
          }

          RuleMark(y: .value("Trung bình", averageBPM))
            .foregroundStyle(.indigo)
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
        .chartXScale(domain: dayRange)
        .chartYAxis {
          AxisMarks(position: .leading)
        }
        .frame(height: 240)
      } header: {
        Text("B — RuleMark(y:) đường trung bình")
      } footer: {
        Text("Đường tím nằm ở \(averageBPM) BPM, trung bình của cả 360 mẫu. Nó chạy suốt chiều rộng kể cả quãng không có dữ liệu — vì không thuộc phần tử nào nên cũng không dừng ở đâu cả.")
      }

      Section {
        Chart {
          ForEach(segmented) { sample in
            LineMark(
              x: .value("Giờ", sample.time),
              y: .value("BPM", sample.bpm),
              series: .value("Đoạn", sample.segment)
            )
            .foregroundStyle(.pink.opacity(0.5))
          }

          RuleMark(y: .value("Ngưỡng", 400))
            .foregroundStyle(.red)
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
        .chartXScale(domain: dayRange)
        .chartYAxis {
          AxisMarks(position: .leading)
        }
        .frame(height: 240)
      } header: {
        Text("C — RuleMark(y:) ở 400, ngoài tầm dữ liệu")
      } footer: {
        Text("Dữ liệu cao nhất chỉ 190. Trục Y có nới lên 400 để chứa đường này không? RectangleMark ở màn Vùng nền thì CÓ — vùng 15.000–20.000 kéo trục lên 20.000 và bóp bẹp mọi cột.")
      }

      Section {
        Chart {
          ForEach(segmented) { sample in
            LineMark(
              x: .value("Giờ", sample.time),
              y: .value("BPM", sample.bpm),
              series: .value("Đoạn", sample.segment)
            )
            .foregroundStyle(.pink.opacity(0.5))
          }

          RuleMark(y: .value("Trung bình", averageBPM))
            .foregroundStyle(.indigo)
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .annotation(position: .top, alignment: .trailing) {
              Text("Trung bình \(averageBPM)")
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.indigo, in: Capsule())
                .fixedSize()
            }
        }
        .chartXScale(domain: dayRange)
        .chartYAxis {
          AxisMarks(position: .leading)
        }
        .frame(height: 240)
      } header: {
        Text("D — annotation trên RuleMark(y:), position: .bottom")
      } footer: {
        Text("Đường NGANG không có đầu trên hay đầu dưới, nên position chỉ quyết định nhãn nằm TRÊN hay DƯỚI đường; vị trí theo chiều ngang phải nói riêng bằng alignment. Ở đây .bottom đặt nhãn dưới đường, .leading dồn về mép trái.")
      }

      Section {
        Chart {
          ForEach(segmented) { sample in
            LineMark(
              x: .value("Giờ", sample.time),
              y: .value("BPM", sample.bpm),
              series: .value("Đoạn", sample.segment)
            )
            .foregroundStyle(.pink.opacity(0.5))
          }

          RuleMark(x: .value("Mốc", noon))
            .foregroundStyle(.indigo)
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .annotation(position: .top) {
              Text("Giữa trưa")
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.indigo, in: Capsule())
                .fixedSize()
            }
        }
        .chartXScale(domain: dayRange)
        .chartYAxis {
          AxisMarks(position: .leading)
        }
        .frame(height: 240)
        .padding(.top, 40)
      } header: {
        Text("E — annotation trên RuleMark(x:), position: .top")
      } footer: {
        Text("Đường DỌC có đầu trên thật, nên .top neo nhãn đúng vào đó và không cần alignment. Đặt cạnh D để thấy cùng một tham số position mang hai nghĩa khác nhau, tuỳ mark là đường ngang hay đường dọc.")
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
