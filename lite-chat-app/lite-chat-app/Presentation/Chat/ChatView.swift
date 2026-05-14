import SwiftUI

struct ChatView: View {
    let chat: Chat
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = ChatViewModel()
    @State private var editingMessage: Message?
    @State private var editedMessageText = ""

    var body: some View {
        VStack(spacing: 0) {
            if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(vm.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isOwn: message.senderId == appState.currentUser?.id
                                )
                                .id(message.id)
                                .contextMenu {
                                    if message.senderId == appState.currentUser?.id {
                                        Button {
                                            editingMessage = message
                                            editedMessageText = message.text
                                        } label: {
                                            Label("Редактировать", systemImage: "pencil")
                                        }

                                        Button(role: .destructive) {
                                            Task {
                                                await vm.deleteMessage(
                                                    chatId: chat.id,
                                                    messageId: message.id,
                                                    token: appState.currentUser?.token ?? ""
                                                )
                                            }
                                        } label: {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .refreshable {
                        await vm.refreshMessages(chatId: chat.id, token: appState.currentUser?.token ?? "")
                    }
                    .onChange(of: vm.messages.count) { _, _ in
                        if let last = vm.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            InputBar(text: $vm.inputText) {
                Task { await vm.sendMessage(chatId: chat.id, token: appState.currentUser?.token ?? "") }
            }
        }
        .navigationTitle(chat.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.fetchMessages(chatId: chat.id, token: appState.currentUser?.token ?? "")
        }
        .onChange(of: appState.currentUser?.id) { _, newValue in
            vm.clear()
            guard newValue != nil else { return }
            Task { await vm.fetchMessages(chatId: chat.id, token: appState.currentUser?.token ?? "") }
        }
        .alert("Редактировать сообщение", isPresented: editAlertBinding) {
            TextField("Текст", text: $editedMessageText)
            Button("Сохранить") {
                guard let editingMessage else { return }
                Task {
                    await vm.editMessage(
                        chatId: chat.id,
                        messageId: editingMessage.id,
                        text: editedMessageText,
                        token: appState.currentUser?.token ?? ""
                    )
                    self.editingMessage = nil
                    editedMessageText = ""
                }
            }
            Button("Отмена", role: .cancel) {
                editingMessage = nil
                editedMessageText = ""
            }
        }
    }

    private var editAlertBinding: Binding<Bool> {
        Binding(
            get: { editingMessage != nil },
            set: { isPresented in
                if !isPresented {
                    editingMessage = nil
                    editedMessageText = ""
                }
            }
        )
    }
}

struct MessageBubble: View {
    let message: Message
    let isOwn: Bool

    var body: some View {
        HStack {
            if isOwn { Spacer(minLength: 60) }
            VStack(alignment: isOwn ? .trailing : .leading, spacing: 3) {
                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isOwn ? Color.accentColor : Color(.systemGray5))
                    .foregroundColor(isOwn ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                Text(footerString(for: message))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }
            if !isOwn { Spacer(minLength: 60) }
        }
    }

    private func footerString(for message: Message) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        let time = f.string(from: message.timestamp)
        return message.updatedAt == nil ? time : "\(time) · изменено"
    }
}

struct InputBar: View {
    @Binding var text: String
    let onSend: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Сообщение", text: $text, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .focused($focused)

            Button {
                onSend()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(text.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary : .accentColor)
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.background)
    }
}
