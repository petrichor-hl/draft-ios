//
//  StepsSelectionScreen.swift
//  Draft
//
//  Apple Health-inspired daily steps chart with sparse hourly data.
//

import Charts
import SwiftUI

private let stepsDayStart = date(2026, 9, 21)
private let stepsDayEnd = date(2026, 9, 22)

private struct HourlySteps: Identifiable {
  let hour: Int
  let steps: Int

  var id: Int { hour }

  var start: Date {
    Calendar.current.date(byAdding: .hour, value: hour, to: stepsDayStart) ?? stepsDayStart
  }

  var rangeLabel: String {
    String(format: "%02d:00–%02d:00", hour, hour + 1)
  }
}

// Only hours with recorded steps appear in the chart.
private let hourlySteps: [HourlySteps] = [
  .init(hour: 6, steps: 30),
  .init(hour: 7, steps: 110),
  .init(hour: 9, steps: 270),
  .init(hour: 11, steps: 510),
  .init(hour: 12, steps: 700),
  .init(hour: 13, steps: 1_089),
  .init(hour: 17, steps: 140),
  .init(hour: 18, steps: 25),
  .init(hour: 19, steps: 140)
]

private struct ChartLongPressGesture: UIGestureRecognizerRepresentable {
  let onSelection: (CGPoint) -> Void

  func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
    let recognizer = UILongPressGestureRecognizer()
    recognizer.minimumPressDuration = 0.25
    recognizer.allowableMovement = 10
    recognizer.cancelsTouchesInView = false
    return recognizer
  }

  func handleUIGestureRecognizerAction(_ recognizer: UILongPressGestureRecognizer, context: Context) {
    guard recognizer.state == .began || recognizer.state == .changed else { return }
    onSelection(context.converter.localLocation)
  }
}

struct StepsSelectionScreen: View {
  @State private var rawSelectedHour: Date?

  private let stepColor = Color(red: 1, green: 0.3, blue: 0)

  private var selectedSample: HourlySteps? {
    guard let rawSelectedHour else { return nil }
    return hourlySteps.last { $0.start <= rawSelectedHour }
  }

  private func selectHour(at x: CGFloat, using proxy: ChartProxy) {
    guard x >= 0, x <= proxy.plotSize.width else {
      rawSelectedHour = nil
      return
    }

    proxy.selectXValue(at: x)
  }

  private func selectionPopover(for sample: HourlySteps) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text("TOTAL")
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)

      HStack(alignment: .firstTextBaseline, spacing: 6) {
        Text(sample.steps.formatted())
          .font(.largeTitle)
          .foregroundStyle(.primary)
        Text("steps")
          .font(.title3)
          .foregroundStyle(.secondary)
      }

      Text("21 Sep, \(String(format: "%02d", sample.hour))–\(String(format: "%02d", sample.hour + 1))")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .padding(10)
    .background(Color(uiColor: .secondarySystemBackground), in: .rect(cornerRadius: 8))
    .fixedSize()
  }

  /// Chỉ những giờ CÓ dữ liệu, đúng như mảng nguồn — giờ trống không có
  /// dòng, giống app Sức khoẻ.
  private var hourlyList: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("HOURLY")
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.bottom, 8)

      ForEach(hourlySteps) { sample in
        HStack(alignment: .firstTextBaseline) {
          Text(sample.rangeLabel)
            .foregroundStyle(.secondary)

          Spacer(minLength: 16)

          Text(sample.steps.formatted())
            .fontWeight(.medium)
            .monospacedDigit()

          Text("steps")
            .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .padding(.vertical, 10)

        if sample.id != hourlySteps.last?.id {
          Divider()
        }
      }
    }
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        VStack(alignment: .leading, spacing: 2) {
          Text("TOTAL")
            .font(.callout.weight(.semibold))
            .foregroundStyle(.secondary)

          HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(hourlySteps.reduce(0) { $0 + $1.steps }.formatted())
              .font(.system(size: 42))
            Text("steps")
              .font(.title3)
              .foregroundStyle(.secondary)
          }

          Text(stepsDayStart.formatted(
            .dateTime.weekday(.abbreviated).day().month(.abbreviated).year()
            .locale(Locale(identifier: "en_GB"))
          ))
          .font(.subheadline)
          .foregroundStyle(.secondary)
        }
        .frame(height: 105, alignment: .topLeading)
        .opacity(selectedSample == nil ? 1 : 0)

        Chart {
          if let selectedSample {
            RuleMark(x: .value("Selected hour", selectedSample.start, unit: .hour))
              .foregroundStyle(Color.gray.s500.opacity(0.4))
              .offset(yStart: -10)
              .zIndex(-1)
              .annotation(
                position: .top,
                spacing: 0,
                overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
              ) {
                selectionPopover(for: selectedSample)
              }
          }

          ForEach(hourlySteps) { sample in
            BarMark(
              x: .value("Hour", sample.start, unit: .hour),
              y: .value("Steps", sample.steps),
              width: .fixed(10)
            )
            .cornerRadius(3)
            .foregroundStyle(stepColor)
          }
        }
        .chartXSelection(value: $rawSelectedHour)
        .chartOverlay { proxy in
          GeometryReader { geometry in
            if let plotFrame = proxy.plotFrame {
              let plotOriginX = geometry[plotFrame].minX

              Color.clear
                .contentShape(Rectangle())
                .gesture(ChartLongPressGesture { location in
                  selectHour(at: location.x - plotOriginX, using: proxy)
                })
                .simultaneousGesture(
                  SpatialTapGesture()
                    .onEnded { tap in
                      selectHour(at: tap.location.x - plotOriginX, using: proxy)
                    }
                )
            }
          }
        }
        .chartXScale(domain: stepsDayStart...stepsDayEnd)
        .chartYScale(domain: 0...1_500)
        .chartXAxis {
          AxisMarks(values: .stride(by: .hour, count: 6)) { value in
            AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2, 3]))
            AxisTick()
            AxisValueLabel {
              if let hour = value.as(Date.self), hour < stepsDayEnd {
                Text(String(format: "%02d", Calendar.current.component(.hour, from: hour)))
              }
            }
          }
        }
        .frame(height: 300)

        Text("Chạm hoặc nhấn giữ để chọn; rê để đổi giờ.")
          .font(.footnote)
          .foregroundStyle(.secondary)
          .padding(.top, 16)

        hourlyList
          .padding(.top, 28)
      }
      .padding()
    }
    .navigationTitle("Steps")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    StepsSelectionScreen()
  }
}
