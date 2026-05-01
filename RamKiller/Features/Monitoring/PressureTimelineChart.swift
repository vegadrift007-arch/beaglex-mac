import SwiftUI
import Charts
import SwiftData

struct PressureTimelineChart: View {
    @Query(sort: \MemorySnapshot.timestamp) private var allSnapshots: [MemorySnapshot]
    let windowHours: Int

    init(windowHours: Int = 1) {
        self.windowHours = windowHours
    }

    private var snapshots: [MemorySnapshot] {
        let cutoff = Date().addingTimeInterval(-Double(windowHours) * 3600)
        return allSnapshots.filter { $0.timestamp >= cutoff }
    }

    var body: some View {
        Chart {
            ForEach(snapshots) { snap in
                BarMark(
                    x: .value("Time", snap.timestamp),
                    y: .value("Level", snap.pressureLevel + 1)
                )
                .foregroundStyle(color(for: snap.pressureLevel))
            }
        }
        .chartYScale(domain: 0...3)
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour().minute())
            }
        }
        .frame(height: 60)
    }

    private func color(for level: Int) -> Color {
        switch level {
        case 0: return .green.opacity(0.4)
        case 1: return .yellow.opacity(0.6)
        default: return .red.opacity(0.7)
        }
    }
}
