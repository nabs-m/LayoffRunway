import Foundation

enum RunwayCalculator {
    static func calculate(input: RunwayInput, calendar: Calendar = .current) -> RunwayResult {
        let safeGrossPaycheck = max(input.grossPaycheck, 0)
        let safeNetPaycheck = max(input.netPaycheck, 0)
        let safeAdditionalDeductions = max(input.paycheckOnlyDeductions, 0)
        let safePartnerMonthlyNetIncome = max(input.partnerMonthlyNetIncome, 0)
        let safeGrossSeverance = max(input.grossSeverance, 0)
        let safeEmergencyFund = max(input.emergencyFund, 0)
        let safeMonthlyBudget = max(input.monthlyBudget, 0)

        let normalizedNet = safeNetPaycheck + safeAdditionalDeductions
        let rawRate = safeGrossPaycheck > 0 ? (1 - (normalizedNet / safeGrossPaycheck)) : 0
        let deductionRate = min(max(rawRate, 0), 1)

        let netSeverance = safeGrossSeverance * (1 - deductionRate)
        let payEstimate = estimatePayThroughTermination(
            referenceDate: input.referenceDate,
            terminationDate: input.terminationDate,
            netPaycheck: safeNetPaycheck,
            calendar: calendar
        )

        let totalAvailableCash = payEstimate.remainingPayNet + netSeverance + safeEmergencyFund
        let effectiveMonthlyBurn = max(safeMonthlyBudget - safePartnerMonthlyNetIncome, 0)
        let runwayMonths = effectiveMonthlyBurn > 0 ? (totalAvailableCash / effectiveMonthlyBurn) : .infinity

        return RunwayResult(
            deductionRate: deductionRate,
            netSeverance: netSeverance,
            remainingPayNet: payEstimate.remainingPayNet,
            fullPaycheckCount: payEstimate.fullPaycheckCount,
            proratedPayNet: payEstimate.proratedPayNet,
            totalAvailableCash: totalAvailableCash,
            runwayMonths: runwayMonths
        )
    }

    private static func estimatePayThroughTermination(
        referenceDate: Date,
        terminationDate: Date,
        netPaycheck: Double,
        calendar: Calendar
    ) -> (remainingPayNet: Double, fullPaycheckCount: Int, proratedPayNet: Double) {
        guard terminationDate >= referenceDate else {
            return (0, 0, 0)
        }

        let paydays = paydaysBetween(start: referenceDate, end: terminationDate, calendar: calendar)
        let fullPaycheckCount = paydays.count
        let fullPayAmount = Double(fullPaycheckCount) * netPaycheck

        let proratedPay = proratedFinalPeriodPay(
            terminationDate: terminationDate,
            netPaycheck: netPaycheck,
            calendar: calendar
        )

        return (fullPayAmount + proratedPay, fullPaycheckCount, proratedPay)
    }

    private static func paydaysBetween(start: Date, end: Date, calendar: Calendar) -> [Date] {
        var results: [Date] = []
        var cursor = calendar.date(from: calendar.dateComponents([.year, .month], from: start)) ?? start

        while cursor <= end {
            let components = calendar.dateComponents([.year, .month], from: cursor)
            guard let year = components.year, let month = components.month else {
                break
            }

            if let fifteenth = calendar.date(from: DateComponents(year: year, month: month, day: 15)),
               fifteenth > start,
               fifteenth <= end {
                results.append(fifteenth)
            }

            if let monthEnd = monthEndDate(year: year, month: month, calendar: calendar),
               monthEnd > start,
               monthEnd <= end {
                results.append(monthEnd)
            }

            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: cursor) else {
                break
            }
            cursor = nextMonth
        }

        return results.sorted()
    }

    private static func proratedFinalPeriodPay(
        terminationDate: Date,
        netPaycheck: Double,
        calendar: Calendar
    ) -> Double {
        if isPayday(terminationDate, calendar: calendar) {
            return 0
        }

        let day = calendar.component(.day, from: terminationDate)
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: terminationDate)) ?? terminationDate

        if day <= 15 {
            guard let periodEnd = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: terminationDate),
                month: calendar.component(.month, from: terminationDate),
                day: 15
            )) else {
                return 0
            }
            let workedDays = day
            let totalDays = calendar.dateComponents([.day], from: monthStart, to: periodEnd).day.map { $0 + 1 } ?? 15
            return netPaycheck * (Double(workedDays) / Double(max(totalDays, 1)))
        }

        guard let periodStart = calendar.date(from: DateComponents(
            year: calendar.component(.year, from: terminationDate),
            month: calendar.component(.month, from: terminationDate),
            day: 16
        )),
        let periodEnd = monthEndDate(
            year: calendar.component(.year, from: terminationDate),
            month: calendar.component(.month, from: terminationDate),
            calendar: calendar
        ) else {
            return 0
        }

        let workedDays = calendar.dateComponents([.day], from: periodStart, to: terminationDate).day.map { $0 + 1 } ?? 1
        let totalDays = calendar.dateComponents([.day], from: periodStart, to: periodEnd).day.map { $0 + 1 } ?? 1
        return netPaycheck * (Double(workedDays) / Double(max(totalDays, 1)))
    }

    private static func isPayday(_ date: Date, calendar: Calendar) -> Bool {
        let day = calendar.component(.day, from: date)
        if day == 15 {
            return true
        }
        let monthEnd = calendar.range(of: .day, in: .month, for: date)?.count ?? 31
        return day == monthEnd
    }

    private static func monthEndDate(year: Int, month: Int, calendar: Calendar) -> Date? {
        guard let anyDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let dayCount = calendar.range(of: .day, in: .month, for: anyDay)?.count else {
            return nil
        }
        return calendar.date(from: DateComponents(year: year, month: month, day: dayCount))
    }
}
