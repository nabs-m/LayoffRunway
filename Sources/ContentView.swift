import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RunwayViewModel()

    var body: some View {
        HStack(spacing: 20) {
            ScenarioFormView(viewModel: viewModel)
                .frame(minWidth: 360, maxWidth: 420)

            ResultsPanelView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(24)
        .background(AppBackground())
    }
}
