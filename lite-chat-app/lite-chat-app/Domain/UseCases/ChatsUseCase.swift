import Foundation

final class ChatsUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(token: String) async throws -> [Chat] {
        try await repository.fetchChats(token: token)
    }
}
