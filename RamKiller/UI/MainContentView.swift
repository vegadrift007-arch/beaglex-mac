import SwiftUI

struct MainContentView: View {
    @State private var selection: SidebarItem? = .monitoring

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 0) {
                // Brand block at top of sidebar
                HStack(spacing: 8) {
                    Image(systemName: "memorychip.fill")
                        .foregroundStyle(Theme.accent)
                        .font(.title2)
                    Text("RamKiller")
                        .font(Theme.display(18))
                        .foregroundStyle(Theme.ink)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)

                SidebarView(selection: $selection)
            }
            .background(Theme.bg2)
        } detail: {
            detailView
                .background(Theme.bg)
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .monitoring:    MonitoringView()
        case .processes:     ProcessesView()
        case .automation:    AutomationView()
        case .cacheCleaner:  CacheCleanerView()
        case .largeFiles:    LargeFilesView()
        case .uninstaller:   UninstallerView()
        case .launchItems:   LaunchItemsView()
        case .settings:      SettingsView()
        case nil:            PlaceholderView(title: "Pick a tool", phase: "—", icon: "sidebar.left")
        }
    }
}

#Preview {
    MainContentView()
        .frame(width: 1100, height: 720)
        .preferredColorScheme(.dark)
}
