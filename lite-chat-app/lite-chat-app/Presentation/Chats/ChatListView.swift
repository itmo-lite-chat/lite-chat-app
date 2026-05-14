import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = ChatsViewModel()
    @State private var isComposePresented = false
    @State private var privateChatUsername = "bobik2"

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Загрузка чатов...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = vm.errorMessage {
                    ContentUnavailableView {
                        Label("Не удалось загрузить", systemImage: "wifi.slash")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Повторить") {
                            Task { await vm.fetchChats(token: appState.currentUser?.token ?? "") }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if vm.chats.isEmpty {
                    ContentUnavailableView(
                        "Нет чатов",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Начните переписку с кем-нибудь")
                    )
                } else {
                    List(vm.chats) { chat in
                        NavigationLink {
                            ChatView(chat: chat)
                        } label: {
                            ChatRowView(chat: chat)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task {
                                    await vm.deleteChat(chat, token: appState.currentUser?.token ?? "")
                                }
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await vm.refreshChats(token: appState.currentUser?.token ?? "")
                    }
                }
            }
            .navigationTitle("Сообщения")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isComposePresented = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
        .task {
            await vm.fetchChats(token: appState.currentUser?.token ?? "")
        }
        .onChange(of: appState.currentUser?.id) { _, newValue in
            vm.clear()
            guard newValue != nil else { return }
            Task { await vm.fetchChats(token: appState.currentUser?.token ?? "") }
        }
        .sheet(isPresented: $isComposePresented) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Username", text: $privateChatUsername)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }
                .navigationTitle("Новый чат")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") {
                            isComposePresented = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Создать") {
                            Task {
                                let chat = await vm.createPrivateChat(
                                    username: privateChatUsername,
                                    token: appState.currentUser?.token ?? ""
                                )
                                if chat != nil {
                                    isComposePresented = false
                                }
                            }
                        }
                        .disabled(privateChatUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isLoading)
                    }
                }
            }
            .presentationDetents([.height(180)])
        }
    }
}

struct ChatRowView: View {
    let chat: Chat

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(avatarColor)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Text(chat.avatarInitials)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                if chat.isOnline {
                    Circle()
                        .fill(.green)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(.background, lineWidth: 2))
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(chat.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(timeString(from: chat.lastMessageTime))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text(chat.lastMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.accentColor)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var avatarColor: Color {
        let colors: [Color] = [.blue, .purple, .pink, .orange, .teal, .indigo]
        return colors[abs(chat.id.hashValue) % colors.count]
    }

    private func timeString(from date: Date) -> String {
        let diff = Date().timeIntervalSince(date)
        if diff < 60 { return "сейчас" }
        if diff < 3600 { return "\(Int(diff / 60)) мин" }
        if diff < 86400 {
            let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: date)
        }
        let f = DateFormatter(); f.dateFormat = "dd.MM"; return f.string(from: date)
    }
}

#Preview {
    ChatListView()
        .environmentObject({
            let s = AppState()
            s.login(user: User(id: "1", username: "demo", displayName: "Demo", token: "mock_jwt_token_abc123"))
            return s
        }())
}
