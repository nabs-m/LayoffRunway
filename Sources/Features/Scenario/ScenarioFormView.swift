import SwiftUI

struct ScenarioFormView: View {
    @ObservedObject var viewModel: RunwayViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Layoff Runway")
                .font(.system(size: 30, weight: .bold, design: .rounded))

            Text("Estimate your runway using expected remaining pay, severance, and your monthly budget.")
                .foregroundStyle(.secondary)

            Form {
                Section("Income Snapshot") {
                    CurrencyInputField(title: "Your gross semi-monthly paycheque", value: $viewModel.grossPaycheck)
                    CurrencyInputField(title: "Your net semi-monthly paycheque", value: $viewModel.netPaycheck)
                    CurrencyInputField(title: "Paycheque-only deductions (optional)", value: $viewModel.paycheckOnlyDeductions)
                    CurrencyInputField(title: "Partner monthly net income (optional)", value: $viewModel.partnerMonthlyNetIncome)
                }

                Section("End of Employment") {
                    DatePicker("Termination date", selection: $viewModel.terminationDate, displayedComponents: .date)
                    CurrencyInputField(title: "Gross severance lump sum", value: $viewModel.grossSeverance)
                }

                Section("Cash Reserves") {
                    CurrencyInputField(title: "Emergency fund (optional)", value: $viewModel.emergencyFund)
                }

                Section("Spending") {
                    CurrencyInputField(title: "Monthly household budget", value: $viewModel.monthlyBudget)
                }
            }
            .formStyle(.grouped)

            HStack(spacing: 10) {
                Button("Calculate Runway") {
                    withAnimation(.easeOut(duration: 0.25)) {
                        viewModel.calculate()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canCalculate)

                Button("Reset") {
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.reset()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct CurrencyInputField: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        HStack {
            Text(title)
            Spacer(minLength: 12)
            TextField("", value: $value, format: .number.precision(.fractionLength(2)), prompt: Text("0.00"))
                .multilineTextAlignment(.trailing)
                .frame(width: 150)
                .textFieldStyle(.roundedBorder)
        }
    }
}
