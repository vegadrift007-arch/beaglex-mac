import Foundation

enum SidebarItem: String, CaseIterable, Identifiable, Hashable {
    case monitoring
    case processes
    case automation
    case cacheCleaner
    case largeFiles
    case uninstaller
    case launchItems
    case settings

    var id: String { rawValue }

    var label: String {
        switch self {
        case .monitoring:   return String(localized: "Memory")
        case .processes:    return String(localized: "Processes")
        case .automation:   return String(localized: "Automation")
        case .cacheCleaner: return String(localized: "Cache Cleaner")
        case .largeFiles:   return String(localized: "Large Files")
        case .uninstaller:  return String(localized: "Uninstaller")
        case .launchItems:  return String(localized: "Launch Items")
        case .settings:     return String(localized: "Settings")
        }
    }

    var icon: String {
        switch self {
        case .monitoring:   return "memorychip"
        case .processes:    return "list.bullet.rectangle"
        case .automation:   return "wand.and.stars"
        case .cacheCleaner: return "trash"
        case .largeFiles:   return "doc.zipper"
        case .uninstaller:  return "shippingbox"
        case .launchItems:  return "rocket"
        case .settings:     return "gearshape"
        }
    }
}
