import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 52, height: 52)
                            .overlay {
                                Text(appState.currentUser?.displayName.prefix(1) ?? "")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(appState.currentUser?.displayName ?? "")
                                .font(.headline)
                            Text("@\(appState.currentUser?.username ?? "")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    Button(role: .destructive) {
                        appState.logout()
                    } label: {
                        Text("Выйти")
                    }
                }
            }
            .navigationTitle("Настройки")
        }
    }
}
