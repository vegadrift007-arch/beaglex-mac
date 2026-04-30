import SwiftUI

struct MenuBarIcon: View {
    @EnvironmentObject private var coordinator: SamplingCoordinator

    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .monospacedDigit()
    }

    private var label: String {
        guard let mem = coordinator.latestMemory else { return "—" }
        return "\(Int(mem.usedPercent.rounded()))%"
    }
}
