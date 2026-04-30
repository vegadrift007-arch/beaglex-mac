import Foundation
import SwiftData

public final class RetentionService {
    private let retentionHours: Int

    public init(retentionHours: Int = 24) {
        self.retentionHours = retentionHours
    }

    public func prune(in context: ModelContext, now: Date = Date()) throws {
        let cutoff = now.addingTimeInterval(-Double(retentionHours) * 3600)

        let memDescriptor = FetchDescriptor<MemorySnapshot>(
            predicate: #Predicate { $0.timestamp < cutoff }
        )
        for old in try context.fetch(memDescriptor) {
            context.delete(old)
        }

        let procDescriptor = FetchDescriptor<ProcessSnapshot>(
            predicate: #Predicate { $0.timestamp < cutoff }
        )
        for old in try context.fetch(procDescriptor) {
            context.delete(old)
        }

        try context.save()
    }
}
