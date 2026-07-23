//
//  LearnCanonicalValue.swift
//  Draft
//
//  Học "Canonical value" trong Measurement / Unit:
//  mọi phép đổi đơn vị đều quy về ĐƠN VỊ GỐC (base unit) rồi mới ra đơn vị đích.
//  Giá trị ở đơn vị gốc đó chính là "canonical value".
//

import SwiftUI

struct LearnCanonicalValue: View {

  /// Giá trị người dùng gõ vào — để quan sát canonical value đổi theo real-time.
  @State private var inputValue: Double = 160
  /// Đơn vị nguồn và đơn vị đích cho phần tương tác — dùng thẳng UnitLength.
  @State private var source: UnitLength = .centimeters
  @State private var target: UnitLength = .inches

  /// UnitLength KHÔNG phải CaseIterable nên phải tự liệt kê danh sách cho Picker.
  private let units: [UnitLength] = [.millimeters, .centimeters, .meters, .kilometers, .miles, .feet, .inches]

  var body: some View {
    List {
      conceptSection
      interactiveSection
      baseUnitSection
      canonicalValueSection
      routeSection
      converterSection
      customUnitSection
      arithmeticSection
    }
    .navigationTitle("Canonical Value")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - 0 · Khái niệm

  @ViewBuilder
  private var conceptSection: some View {
    Section("0 · Canonical value là gì?") {
      VStack(alignment: .leading, spacing: 8) {
        Text("Mỗi Dimension (UnitLength, UnitMass, UnitTemperature…) có MỘT đơn vị gốc — baseUnit(). Mọi đơn vị khác quy về đơn vị gốc bằng công thức:")
          .font(.callout)
        Text("canonical = value × coefficient + constant")
          .font(.callout.monospaced().bold())
          .frame(maxWidth: .infinity)
          .padding(.vertical, 6)
          .background(.quaternary, in: .rect(cornerRadius: 8))
        Text("Giá trị ở đơn vị gốc = canonical value. Đây là \"ngôn ngữ chung\" để các đơn vị cùng loại so sánh, cộng và đổi qua lại được.")
          .font(.callout)
          .foregroundStyle(.secondary)
      }
    }
  }

  // MARK: - 1 · Tương tác

  @ViewBuilder
  private var interactiveSection: some View {
    // Measurement nguồn từ input.
    let m = Measurement(value: inputValue, unit: source)

    // Canonical value = quy về base unit (mét). Hai cách cho ra cùng kết quả:
    //  a) đi qua Measurement API: .converted(to: .baseUnit())
    let canonicalViaMeasurement = m.converted(to: UnitLength.baseUnit()).value
    //  b) đi thẳng qua converter số học: converter.baseUnitValue(fromValue:)
    //  let canonicalViaConverter = source.converter.baseUnitValue(fromValue: inputValue)

    let converted = m.converted(to: target)

    // ⚠️ BẪY: .formatted() trần dùng usage: .general -> tự chọn LẠI đơn vị "tự nhiên"
    // theo locale, BỎ QUA đơn vị vừa convert (vd 3 mi ở vi locale bị đổi hiển thị về km).
    // Dùng usage: .asProvided để GIỮ NGUYÊN đơn vị đã convert.
    let keepUnit = Measurement<UnitLength>.FormatStyle.measurement(
      width: .abbreviated, usage: .asProvided
    )

    Section {
      TextField("Giá trị", value: $inputValue, format: .number)
        .keyboardType(.decimalPad)
        .font(.title3.monospaced())

      Picker("Đơn vị nguồn", selection: $source) {
        // UnitLength không Identifiable -> id: \.self (được vì nó Hashable).
        // symbol cho sẵn nhãn "km", "mm", "mi"… nên khỏi cần label thủ công.
        ForEach(units, id: \.self) { Text($0.symbol).tag($0) }
      }
      Picker("Đơn vị đích", selection: $target) {
        ForEach(units, id: \.self) { Text($0.symbol).tag($0) }
      }

      row("Nhập vào", m.formatted(keepUnit))
      row("→ Canonical (base = mét)", "\(canonicalViaMeasurement) m")
      row("→ Đổi sang đích", converted.formatted(keepUnit))
      row("→ Đổi sang đích (.formatted() trần ⚠️)", converted.formatted())
    } header: {
      Text("1 · Gõ số & quan sát canonical")
    }
  }

  // MARK: - 2 · baseUnit của mỗi Dimension

  @ViewBuilder
  private var baseUnitSection: some View {
    Section {
      row("UnitLength", UnitLength.baseUnit().symbol)          // m
      row("UnitMass", UnitMass.baseUnit().symbol)              // kg
      row("UnitDuration", UnitDuration.baseUnit().symbol)      // s
      row("UnitTemperature", UnitTemperature.baseUnit().symbol) // K
      row("UnitSpeed", UnitSpeed.baseUnit().symbol)            // m/s
      row("UnitArea", UnitArea.baseUnit().symbol)              // m²
    } header: {
      Text("2 · baseUnit() — đơn vị gốc (canonical)")
    } footer: {
      Text("baseUnit() là class method trên Dimension. Canonical value luôn được đo bằng đơn vị này.")
    }
  }

  // MARK: - 3 · Canonical value thực tế

  @ViewBuilder
  private var canonicalValueSection: some View {
    Section {
      row("1 km → canonical", "\(UnitLength.kilometers.converter.baseUnitValue(fromValue: 1).formatted()) m")
      row("1 mile → canonical", "\(UnitLength.miles.converter.baseUnitValue(fromValue: 1).formatted()) m")
      row("1 ft → canonical", "\(UnitLength.feet.converter.baseUnitValue(fromValue: 1).formatted()) m")
      row("1 kg → canonical", "\(UnitMass.kilograms.converter.baseUnitValue(fromValue: 1).formatted()) kg")
      row("1 pound → canonical", "\(UnitMass.pounds.converter.baseUnitValue(fromValue: 1).formatted()) kg")
    } header: {
      Text("3 · Canonical value = quy về base unit")
    } footer: {
      Text("converter.baseUnitValue(fromValue:) trả về giá trị canonical trực tiếp, không cần tạo Measurement.")
    }
  }

  // MARK: - 4 · Đổi đơn vị đi qua canonical

  @ViewBuilder
  private var routeSection: some View {
    let five = Measurement(value: 5, unit: UnitLength.kilometers)
    Section {
      row("Bắt đầu", "5 km")
      row("Bước 1: → canonical (mét)", "\(five.converted(to: .meters).value.formatted()) m")
      row("Bước 2: canonical → miles", "\(five.converted(to: .miles).value.formatted()) mi")
    } header: {
      Text("4 · km → canonical → miles")
    } footer: {
      Text("Foundation KHÔNG đổi km→miles trực tiếp. Nó đi 2 bước: về mét (canonical) rồi ra miles. Mét là điểm trung chuyển chung.")
    }
  }

  // MARK: - 5 · UnitConverterLinear: coefficient & constant

  @ViewBuilder
  private var converterSection: some View {
    Section {
      row("km", linear(UnitLength.kilometers))          // coeff 1000, const 0
      row("mile", linear(UnitLength.miles))             // coeff 1609.344
      row("°C", linear(UnitTemperature.celsius))        // coeff 1, const 273.15
      row("°F", linear(UnitTemperature.fahrenheit))     // coeff ~0.5556, const ~255.37
      row("0 °C → canonical", "\(Measurement(value: 0, unit: UnitTemperature.celsius).converted(to: .kelvin).value.formatted()) K")
    } header: {
      Text("5 · coefficient & constant")
    } footer: {
      Text("Length có constant = 0 (tuyến tính thuần). Nhiệt độ có constant ≠ 0 (affine): 0°C không phải 0K, mà là 273.15K. constant chính là điểm gốc lệch nhau.")
    }
  }

  // MARK: - 6 · Custom Unit

  @ViewBuilder
  private var customUnitSection: some View {
    // Tự định nghĩa đơn vị "sải tay" ≈ 1.7 m.
    // coefficient = 1.7 nghĩa: 1 sải = 1.7 m (canonical).
    let saiTay = UnitLength(symbol: "sải", converter: UnitConverterLinear(coefficient: 1.7))
    let m = Measurement(value: 3, unit: saiTay)
    Section {
      row("Định nghĩa", "1 sải = 1.7 m (coefficient 1.7)")
      row("3 sải → canonical", "\(m.converted(to: .meters).value.formatted()) m")
      row("3 sải → km", "\(m.converted(to: .kilometers).value.formatted()) km")
    } header: {
      Text("6 · Tự định nghĩa đơn vị")
    } footer: {
      Text("Chỉ cần khai báo coefficient (quan hệ với đơn vị gốc), đơn vị mới lập tức đổi qua lại được với MỌI đơn vị length khác — nhờ đi qua canonical.")
    }
  }

  // MARK: - 7 · Cộng & so sánh

  @ViewBuilder
  private var arithmeticSection: some View {
    let a = Measurement(value: 1, unit: UnitLength.kilometers)
    let b = Measurement(value: 300, unit: UnitLength.meters)
    Section {
      row("1 km + 300 m", (a + b).converted(to: .meters).value.formatted() + " m")
      row("1 km > 900 m ?", "\(a > Measurement(value: 900, unit: .meters))")
    } header: {
      Text("7 · Cộng & so sánh khác đơn vị")
    } footer: {
      Text("Cộng/so sánh được dù khác đơn vị vì Measurement tự quy cả hai về canonical value rồi mới tính.")
    }
  }

  // MARK: - Helpers

  /// Đọc coefficient & constant từ converter (nếu là tuyến tính) để hiển thị.
  private func linear(_ unit: Dimension) -> String {
    guard let c = unit.converter as? UnitConverterLinear else { return "n/a" }
    return "coeff \(c.coefficient.formatted()), const \(c.constant.formatted())"
  }

  private func row(_ title: LocalizedStringKey, _ value: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(value)
        .font(.callout.monospaced())
        .textSelection(.enabled)
    }
  }
}

#Preview {
  NavigationStack {
    LearnCanonicalValue()
  }
}
