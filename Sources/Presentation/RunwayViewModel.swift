import Foundation
import SwiftUI

@MainActor
final class RunwayViewModel: ObservableObject {
    @Published var grossPaycheck: Double {
        didSet { save("grossPaycheck", grossPaycheck) }
    }
    @Published var netPaycheck: Double {
        didSet { save("netPaycheck", netPaycheck) }
    }
    @Published var paycheckOnlyDeductions: Double {
        didSet { save("paycheckOnlyDeductions", paycheckOnlyDeductions) }
    }
    @Published var terminationDate: Date {
        didSet { save("terminationDate", terminationDate.timeIntervalSince1970) }
    }
    @Published var grossSeverance: Double {
        didSet { save("grossSeverance", grossSeverance) }
    }
    @Published var emergencyFund: Double {
        didSet { save("emergencyFund", emergencyFund) }
    }
    @Published var monthlyBudget: Double {
        didSet { save("monthlyBudget", monthlyBudget) }
    }

    @Published private(set) var result: RunwayResult?
    @Published private(set) var lastCalculatedAt: Date?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.grossPaycheck = defaults.double(forKey: "grossPaycheck")
        self.netPaycheck = defaults.double(forKey: "netPaycheck")
        self.paycheckOnlyDeductions = defaults.double(forKey: "paycheckOnlyDeductions")
        let savedTermination = defaults.double(forKey: "terminationDate")
        self.terminationDate = savedTermination > 0
            ? Date(timeIntervalSince1970: savedTermination)
            : Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date()
        self.grossSeverance = defaults.double(forKey: "grossSeverance")
        self.emergencyFund = defaults.double(forKey: "emergencyFund")
        self.monthlyBudget = defaults.double(forKey: "monthlyBudget")
    }

    var canCalculate: Bool {
        grossPaycheck > 0 &&
        netPaycheck >= 0 &&
        grossSeverance >= 0 &&
        monthlyBudget > 0
    }

    var inferredDeductionRateLabel: String {
        guard let result else { return "-" }
        return NumberFormatters.percent.string(from: NSNumber(value: result.deductionRate)) ?? "-"
    }

    func calculate() {
        guard canCalculate else { return }

        let input = RunwayInput(
            referenceDate: Date(),
            terminationDate: terminationDate,
            grossPaycheck: grossPaycheck,
            netPaycheck: netPaycheck,
            paycheckOnlyDeductions: paycheckOnlyDeductions,
            grossSeverance: grossSeverance,
            emergencyFund: emergencyFund,
            monthlyBudget: monthlyBudget
        )

        result = RunwayCalculator.calculate(input: input)
        lastCalculatedAt = Date()
    }

    func reset() {
        grossPaycheck = 0
        netPaycheck = 0
        paycheckOnlyDeductions = 0
        terminationDate = Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date()
        grossSeverance = 0
        emergencyFund = 0
        monthlyBudget = 0
        result = nil
        lastCalculatedAt = nil
    }

    private let defaults: UserDefaults

    private func save(_ key: String, _ value: Double) {
        defaults.set(value, forKey: key)
    }
}

enum NumberFormatters {
    static let currency: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")

    static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        return formatter
    }()

    static let oneDecimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        return formatter
    }()
}
