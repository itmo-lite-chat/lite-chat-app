import Foundation

@MainActor
final class DIContainer {
    static let shared = DIContainer()
    private init() {}

    let authUseCase = AuthUseCase(repository: APIService.shared)
    let chatsUseCase = ChatsUseCase(repository: APIService.shared)
    let messagesUseCase = MessagesUseCase(repository: APIService.shared)
}
