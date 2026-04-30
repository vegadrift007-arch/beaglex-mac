import Foundation

public actor ScannerService {
    public init() {}

    public func computeSize(for cleaner: Cleaner) -> Int64 {
        var total: Int64 = 0
        for p in cleaner.paths {
            for resolved in PathExpander.expand(p) {
                total += sizeOf(path: resolved)
            }
        }
        return total
    }

    public func computeSizes(for cleaners: [Cleaner]) async -> [String: Int64] {
        await withTaskGroup(of: (String, Int64).self) { group in
            for c in cleaners {
                group.addTask { (c.id, await self.computeSize(for: c)) }
            }
            var result: [String: Int64] = [:]
            for await (id, size) in group {
                result[id] = size
            }
            return result
        }
    }

    private func sizeOf(path: String) -> Int64 {
        let url = URL(fileURLWithPath: path)
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir) else { return 0 }
        if isDir.boolValue {
            var total: Int64 = 0
            if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                for case let fileURL as URL in enumerator {
                    let res = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                    if res?.isDirectory == false {
                        total += Int64(res?.fileSize ?? 0)
                    }
                }
            }
            return total
        }
        let res = try? url.resourceValues(forKeys: [.fileSizeKey])
        return Int64(res?.fileSize ?? 0)
    }
}
