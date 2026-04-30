import Foundation
import Shared

final class HelperService: NSObject, NSXPCListenerDelegate, HelperProtocol {
    static let version = "0.2.0"

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection conn: NSXPCConnection) -> Bool {
        // For self-use: accept all connections. Hardening (code-sign requirement validation)
        // is a future phase — see plan file for FIXME.
        conn.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        conn.exportedObject = self
        conn.resume()
        return true
    }

    // MARK: HelperProtocol

    func helperVersion(reply: @escaping (String) -> Void) {
        reply(Self.version)
    }

    func execute(commandData: Data, reply: @escaping (Data) -> Void) {
        do {
            let cmd = try JSONDecoder().decode(HelperCommand.self, from: commandData)
            let result = run(cmd)
            let data = try JSONEncoder().encode(result)
            reply(data)
        } catch {
            let err = HelperResult.failed(error: "decode failed: \(error.localizedDescription)")
            let data = (try? JSONEncoder().encode(err)) ?? Data()
            reply(data)
        }
    }

    private func run(_ cmd: HelperCommand) -> HelperResult {
        switch cmd {
        case .purgeMemory:
            if let err = PurgeOperation.run() {
                return .failed(error: err)
            }
            return .success
        case .killProcess(let pid, let sig):
            switch KillOperation.run(pid: pid, signal: sig) {
            case .success:                return .success
            case .denied(let r):          return .denied(reason: r)
            case .failed(let e):          return .failed(error: e)
            }
        case .unloadLaunchPlist(let path):
            return adapt(LaunchItemOperation.unload(path: path))
        case .loadLaunchPlist(let path):
            return adapt(LaunchItemOperation.load(path: path))
        case .renamePlist(let from, let to):
            return adapt(LaunchItemOperation.rename(from: from, to: to))
        case .deletePlist(let path):
            return adapt(LaunchItemOperation.delete(path: path))
        }
    }

    private func adapt(_ outcome: LaunchItemOperation.Outcome) -> HelperResult {
        switch outcome {
        case .success:        return .success
        case .denied(let r):  return .denied(reason: r)
        case .failed(let e):  return .failed(error: e)
        }
    }
}
