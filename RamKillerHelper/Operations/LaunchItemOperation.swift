import Foundation

enum LaunchItemOperation {
    /// Allowed parent directories for any plist operation.
    private static let allowedRoots = [
        "/Library/LaunchAgents/",
        "/Library/LaunchDaemons/"
    ]

    enum Outcome {
        case success
        case denied(reason: String)
        case failed(error: String)
    }

    static func unload(path: String) -> Outcome {
        guard isAllowed(path) else { return .denied(reason: "Path \(path) outside allowed roots") }
        return runLaunchctl(args: ["bootout", "system/\(label(from: path))"])
    }

    static func load(path: String) -> Outcome {
        guard isAllowed(path) else { return .denied(reason: "Path \(path) outside allowed roots") }
        return runLaunchctl(args: ["bootstrap", "system", path])
    }

    static func rename(from: String, to: String) -> Outcome {
        guard isAllowed(from), isAllowed(to) else { return .denied(reason: "Path outside allowed roots") }
        do {
            try FileManager.default.moveItem(atPath: from, toPath: to)
            return .success
        } catch {
            return .failed(error: error.localizedDescription)
        }
    }

    static func delete(path: String) -> Outcome {
        guard isAllowed(path) else { return .denied(reason: "Path \(path) outside allowed roots") }
        do {
            try FileManager.default.removeItem(atPath: path)
            return .success
        } catch {
            return .failed(error: error.localizedDescription)
        }
    }

    private static func isAllowed(_ path: String) -> Bool {
        allowedRoots.contains { path.hasPrefix($0) }
    }

    private static func label(from path: String) -> String {
        let file = (path as NSString).lastPathComponent
        return (file as NSString).deletingPathExtension
    }

    private static func runLaunchctl(args: [String]) -> Outcome {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        task.arguments = args
        let stderr = Pipe()
        task.standardError = stderr
        task.standardOutput = Pipe()
        do {
            try task.run()
            task.waitUntilExit()
            if task.terminationStatus == 0 { return .success }
            let data = stderr.fileHandleForReading.readDataToEndOfFile()
            let msg = String(data: data, encoding: .utf8) ?? "exit \(task.terminationStatus)"
            return .failed(error: msg)
        } catch {
            return .failed(error: error.localizedDescription)
        }
    }
}
