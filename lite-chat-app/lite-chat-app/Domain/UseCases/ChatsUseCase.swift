import Foundation

final class ChatsUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(token: String) async throws -> [Chat] {
        try await repository.fetchChats(token: token)
    }

    func createPrivateChat(username: String, token: String) async throws -> Chat {
        try await repository.createPrivateChat(username: username, token: token)
    }

    func deleteChat(chatId: String, token: String) async throws {
        try await repository.deleteChat(chatId: chatId, token: token)
    }
}
