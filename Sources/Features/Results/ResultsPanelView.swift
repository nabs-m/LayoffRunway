import SwiftUI

struct ResultsPanelView: View {
    @ObservedObject var viewModel: RunwayViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let result = viewModel.result {
                ResultCardView(
                    title: "Estimated Runway",
                    value: runwayLabel(months: result.runwayMonths),
                    subtitle: "Based on household budget after partner income"
                )
                .transition(.move(edge: .top).combined(with: .opacity))

                HStack(spacing: 12) {
                    ResultCardView(
                        title: "Total Available Cash",
                        value: currency(result.totalAvailableCash),
                        subtitle: nil
                    )

                    ResultCardView(
                        title: "Estimated Net Severance",
                        value: currency(result.netSeverance),
                        subtitle: nil
                    )
                }

                HStack(spacing: 12) {
                    ResultCardView(
                        title: "Remaining Pay Before End Date",
                        value: currency(result.remainingPayNet),
                        subtitle: result.fullPaycheckCount == 1 ? "1 full paycheque + proration" : "\(result.fullPaycheckCount) full paycheques + proration"
                    )

                    ResultCardView(
                        title: "Inferred Deductions",
                        value: viewModel.inferredDeductionRateLabel,
                        subtitle: "Derived from gross vs net pay"
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("How this estimate works")
                        .font(.headline)

                    Text("1) We infer an effective deduction rate from your gross and net paycheque, after adding back any paycheque-only deductions.")
                    Text("2) We apply that same deduction rate to your gross severance lump sum to estimate net severance.")
                    Text("3) We add estimated pay remaining through your termination date and emergency fund, then divide by monthly budget after partner income.")
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(14)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))

                Spacer(minLength: 0)
            } else {
                PlaceholderResultView()
            }
        }
    }

    private func runwayLabel(months: Double) -> String {
        if months.isInfinite {
            return "Not depleted"
        }

        let safeMonths = max(months, 0)
        let monthCount = Int(floor(safeMonths))
        let fraction = safeMonths - Double(monthCount)
        let approxDays = Int((fraction * 30).rounded())

        if monthCount == 0 {
            return "~\(approxDays) days"
        }

        return "\(monthCount) mo \(approxDays)d"
    }

    private func currency(_ value: Double) -> String {
        value.formatted(NumberFormatters.currency)
    }
}

private struct PlaceholderResultView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Runway Estimate")
                .font(.system(size: 30, weight: .bold, design: .rounded))

            Text("Fill in your scenario and click Calculate Runway to see your estimated months of runway.")
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}
