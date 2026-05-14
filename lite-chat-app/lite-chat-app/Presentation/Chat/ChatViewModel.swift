import SwiftUI
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText = ""
    @Published var isLoading = false

    private let messagesUseCase: MessagesUseCase

    init() {
        self.messagesUseCase = DIContainer.shared.messagesUseCase
    }

    func fetchMessages(chatId: String, token: String) async {
        isLoading = true
        do {
            messages = try await messagesUseCase.fetchMessages(chatId: chatId, token: token)
        } catch {}
        isLoading = false
    }

    func sendMessage(chatId: String, token: String) async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""

        let optimistic = Message(id: UUID().uuidString, senderId: "usr_001", text: text, timestamp: Date())
        messages.append(optimistic)

        _ = try? await messagesUseCase.sendMessage(chatId: chatId, text: text, token: token)
    }
}
