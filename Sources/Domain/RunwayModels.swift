import Foundation

struct RunwayInput {
    let referenceDate: Date
    let terminationDate: Date
    let grossPaycheck: Double
    let netPaycheck: Double
    let paycheckOnlyDeductions: Double
    let grossSeverance: Double
    let emergencyFund: Double
    let monthlyBudget: Double
}

struct RunwayResult {
    let deductionRate: Double
    let netSeverance: Double
    let remainingPayNet: Double
    let fullPaycheckCount: Int
    let proratedPayNet: Double
    let totalAvailableCash: Double
    let runwayMonths: Double
}
