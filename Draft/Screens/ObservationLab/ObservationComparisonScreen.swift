//
//  ObservationComparisonScreen.swift
//  Draft
//
//  Thử nghiệm: @Observable (per-property tracking) vs ObservableObject (object-level).

import SwiftUI
import Combine

// MARK: - Stores

// Equatable có chủ đích — kết quả thực nghiệm:
// - @Observable: setter sinh ra bởi macro có guard `shouldNotifyObservers`:
//   type Equatable so sánh `!=`, class so sánh `!==`, còn lại luôn notify.
//   → gán giá trị y hệt sẽ KHÔNG notify, không re-render.
// - @Published: dùng willSet, không so sánh gì → gán y hệt vẫn re-render.
// Thử xóa `: Equatable` để thấy test 4️⃣ bên @Observable re-render trở lại.
//
// Với MẢNG — conditional conformance của standard library:
//   extension Array: Equatable where Element: Equatable { }
// nghĩa là Array chỉ Equatable khi PHẦN TỬ Equatable, lan truyền tự động:
// - Int Equatable sẵn → [Int] Equatable → test 5️⃣ (mảng y hệt) bị dedup.
// - Meal: Equatable → [Meal] Equatable → gán mảng Meal y hệt cũng không re-render
//   (đã kiểm chứng bằng withObservationTracking, onChange không bắn).
// - Xóa `: Equatable` khỏi Meal → [Meal] MẤT LUÔN Equatable → gán y hệt vẫn notify.
// Hệ quả: model struct nhỏ nhất thiếu Equatable là cả mảng chứa nó mất quyền dedup.
// Áp dụng Dietfit: `store.meals = try await api.fetchMeals()` — data không đổi
// thì không tốn render nào, miễn là Meal conform Equatable. So sánh mảng là O(n),
// gần như luôn rẻ hơn chi phí re-render tiết kiệm được.
struct Meal: Equatable {
  var name: String
  var kcal: Int
}

@Observable
final class ModernDiaryStore {
  var todayCalories = 0
  var waterMl = 0
  var lastMeal = Meal(name: "Oatmeal", kcal: 300)
  var weights: [Int] = [60, 61]
}

final class LegacyDiaryStore: ObservableObject {
  @Published var todayCalories = 0
  @Published var waterMl = 0
  @Published var lastMeal = Meal(name: "Oatmeal", kcal: 300)
  @Published var weights: [Int] = [60, 61]
}


private enum RenderCounter {
  static var counts: [String: Int] = [:]
  
  static func bump(_ key: String) -> Int {
    counts[key, default: 0] += 1
    return counts[key]!
  }
}

// MARK: - Card UI chung

private struct CardBody: View {
  let title: LocalizedStringKey
  let value: String
  let renders: Int
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(value)
        .font(.title3.bold())
      Text("body chạy: \(renders) lần")
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .background(
      Color(hue: .random(in: 0...1), saturation: 0.35, brightness: 0.95),
      in: RoundedRectangle(cornerRadius: 12)
    )
  }
}

// MARK: - Cards cho @Observable

private struct ModernCalorieCard: View {
  @Environment(ModernDiaryStore.self) private var store
  
  var body: some View {
    let _ = Self._printChanges()
    CardBody(
      title: "CalorieCard — đọc todayCalories",
      value: "\(store.todayCalories) kcal",
      renders: RenderCounter.bump("modern-calorie")
    )
  }
}

private struct ModernWaterCard: View {
  @Environment(ModernDiaryStore.self) private var store
  
  var body: some View {
    let _ = Self._printChanges()
    CardBody(
      title: "WaterCard — đọc waterMl",
      value: "\(store.waterMl) ml",
      renders: RenderCounter.bump("modern-water")
    )
  }
}

private struct ModernMealCard: View {
  @Environment(ModernDiaryStore.self) private var store

  var body: some View {
    let _ = Self._printChanges()
    CardBody(
      title: "MealCard — đọc lastMeal",
      value: "\(store.lastMeal.name) (\(store.lastMeal.kcal) kcal)",
      renders: RenderCounter.bump("modern-meal")
    )
  }
}

private struct ModernWeightsCard: View {
  @Environment(ModernDiaryStore.self) private var store

  var body: some View {
    let _ = Self._printChanges()
    CardBody(
      title: "WeightsCard — đọc weights",
      value: store.weights.map(String.init).joined(separator: ", "),
      renders: RenderCounter.bump("modern-weights")
    )
  }
}

// MARK: - Cards cho ObservableObject

private struct LegacyCalorieCard: View {
  @EnvironmentObject private var store: LegacyDiaryStore
  
  var body: some View {
    let _ = Self._printChanges()
    CardBody(
      title: "CalorieCard — đọc todayCalories",
      value: "\(store.todayCalories) kcal",
      renders: RenderCounter.bump("legacy-calorie")
    )
  }
}

private struct LegacyWaterCard: View {
  @EnvironmentObject private var store: LegacyDiaryStore
  
  var body: some View {
    let _ = Self._printChanges()
    CardBody(
      title: "WaterCard — đọc waterMl",
      value: "\(store.waterMl) ml",
      renders: RenderCounter.bump("legacy-water")
    )
  }
}

private struct LegacyMealCard: View {
  @EnvironmentObject private var store: LegacyDiaryStore

  var body: some View {
    let _ = Self._printChanges()
    CardBody(
      title: "MealCard — đọc lastMeal",
      value: "\(store.lastMeal.name) (\(store.lastMeal.kcal) kcal)",
      renders: RenderCounter.bump("legacy-meal")
    )
  }
}

private struct LegacyWeightsCard: View {
  @EnvironmentObject private var store: LegacyDiaryStore

  var body: some View {
    let _ = Self._printChanges()
    CardBody(
      title: "WeightsCard — đọc weights",
      value: store.weights.map(String.init).joined(separator: ", "),
      renders: RenderCounter.bump("legacy-weights")
    )
  }
}

// MARK: - 5 test buttons dùng chung cho cả 2 section
// Nhận closures nên không đụng store nào → không subscribe gì.

private struct ValueTestButtons: View {
  let currentMeal: () -> Meal
  let currentWeights: () -> [Int]
  let setMeal: (Meal) -> Void
  let setWeights: ([Int]) -> Void
  let appendWeight: (Int) -> Void
  let removeLastWeight: () -> Void

  private static let mealNames = ["Phở", "Cơm gà", "Bún chả", "Bánh mì"]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Button("1️⃣ Meal mới, giá trị khác") {
          setMeal(Meal(name: Self.mealNames.randomElement()!, kcal: Int.random(in: 200...800)))
        }
        Button("4️⃣ Meal mới, y hệt") {
          let old = currentMeal()
          setMeal(Meal(name: old.name, kcal: old.kcal))
        }
      }
      HStack {
        Button("2️⃣ Append") { appendWeight(Int.random(in: 55...70)) }
        Button("2️⃣ RemoveLast") { removeLastWeight() }
      }
      HStack {
        Button("3️⃣ Mảng mới, khác") {
          setWeights((0..<Int.random(in: 1...4)).map { _ in Int.random(in: 55...70) })
        }
        Button("5️⃣ Mảng mới, y hệt") {
          setWeights(currentWeights())
        }
      }
    }
    .font(.caption)
    .buttonStyle(.bordered)
  }
}

// MARK: - Section cho từng cơ chế

private struct ModernSection: View {
  @Environment(ModernDiaryStore.self) var store
  
  var body: some View {
    let _ = print("ModernSection render")
    VStack(alignment: .leading, spacing: 12) {
      Text("@Observable — track từng property")
        .font(.headline)
      
      ModernCalorieCard()
      ModernWaterCard()
      ModernMealCard()
      ModernWeightsCard()

      HStack {
        Button("+100 kcal") { store.todayCalories += 100 }
        Button("+250 ml") { store.waterMl += 250 }
      }
      .buttonStyle(.bordered)

      ValueTestButtons(
        currentMeal: { store.lastMeal },
        currentWeights: { store.weights },
        setMeal: { store.lastMeal = $0 },
        setWeights: { store.weights = $0 },
        appendWeight: { store.weights.append($0) },
        removeLastWeight: { if !store.weights.isEmpty { store.weights.removeLast() } }
      )
    }

  }
}

private struct LegacySection: View {
  @EnvironmentObject var store: LegacyDiaryStore
  
  var body: some View {
    let _ = print("LegacySection render")
    VStack(alignment: .leading, spacing: 12) {
      Text("ObservableObject — track cả object")
        .font(.headline)
      
      LegacyCalorieCard()
      LegacyWaterCard()
      LegacyMealCard()
      LegacyWeightsCard()

      HStack {
        Button("+100 kcal") { store.todayCalories += 100 }
        Button("+250 ml") { store.waterMl += 250 }
      }
      .buttonStyle(.bordered)

      ValueTestButtons(
        currentMeal: { store.lastMeal },
        currentWeights: { store.weights },
        setMeal: { store.lastMeal = $0 },
        setWeights: { store.weights = $0 },
        appendWeight: { store.weights.append($0) },
        removeLastWeight: { if !store.weights.isEmpty { store.weights.removeLast() } }
      )
    }

  }
}

// MARK: - Screen

struct ObservationComparisonScreen: View {
  @State private var modernStore = ModernDiaryStore()
  @StateObject private var legacyStore = LegacyDiaryStore()
  
  var body: some View {
    let _ = print("ObservationComparisonScreen render")
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text("Bấm **+100 kcal** ở mỗi section rồi quan sát WaterCard: màu nền đổi + số lần body tăng = có re-render.")
          .font(.footnote)
          .foregroundStyle(.secondary)
        
        ModernSection()
        
        Divider()
        
        LegacySection()
      }
      .padding()
    }
    .environment(modernStore)
    .environmentObject(legacyStore)
    .navigationTitle("Observable vs ObservableObject")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    ObservationComparisonScreen()
  }
}
