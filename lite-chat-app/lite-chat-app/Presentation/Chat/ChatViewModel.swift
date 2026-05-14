import SwiftUI
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let messagesUseCase: MessagesUseCase

    init() {
        self.messagesUseCase = DIContainer.shared.messagesUseCase
    }

    func fetchMessages(chatId: String, token: String, showLoading: Bool = true) async {
        if showLoading {
            isLoading = true
        }
        errorMessage = nil
        do {
            messages = try await messagesUseCase.fetchMessages(chatId: chatId, token: token)
        } catch {
            if showLoading {
                messages = []
            }
            errorMessage = error.localizedDescription
        }
        if showLoading {
            isLoading = false
        }
    }

    func refreshMessages(chatId: String, token: String) async {
        await fetchMessages(chatId: chatId, token: token, showLoading: false)
    }

    func sendMessage(chatId: String, token: String) async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""

        do {
            let message = try await messagesUseCase.sendMessage(chatId: chatId, text: text, token: token)
            messages.append(message)
        } catch {
            inputText = text
            errorMessage = error.localizedDescription
        }
    }

    func editMessage(chatId: String, messageId: String, text: String, token: String) async {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        do {
            let updatedMessage = try await messagesUseCase.editMessage(
                chatId: chatId,
                messageId: messageId,
                text: text,
                token: token
            )
            if let index = messages.firstIndex(where: { $0.id == messageId }) {
                messages[index] = updatedMessage
            } else {
                await refreshMessages(chatId: chatId, token: token)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteMessage(chatId: String, messageId: String, token: String) async {
        do {
            try await messagesUseCase.deleteMessage(chatId: chatId, messageId: messageId, token: token)
            messages.removeAll { $0.id == messageId }
        } catch {
            errorMessage = error.localizedDescription
            await refreshMessages(chatId: chatId, token: token)
        }
    }

    func clear() {
        messages = []
        inputText = ""
        errorMessage = nil
        isLoading = false
    }
}
