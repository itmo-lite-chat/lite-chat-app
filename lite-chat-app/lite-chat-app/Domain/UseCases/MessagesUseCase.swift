import Foundation

final class MessagesUseCase {
    private let repository: MessageRepositoryProtocol

    init(repository: MessageRepositoryProtocol) {
        self.repository = repository
    }

    func fetchMessages(chatId: String, token: String) async throws -> [Message] {
        try await repository.fetchMessages(chatId: chatId, token: token)
    }

    func sendMessage(chatId: String, text: String, token: String) async throws -> Message {
        try await repository.sendMessage(chatId: chatId, text: text, token: token)
    }

    func editMessage(chatId: String, messageId: String, text: String, token: String) async throws -> Message {
        try await repository.editMessage(chatId: chatId, messageId: messageId, text: text, token: token)
    }

    func deleteMessage(chatId: String, messageId: String, token: String) async throws {
        try await repository.deleteMessage(chatId: chatId, messageId: messageId, token: token)
    }
}
