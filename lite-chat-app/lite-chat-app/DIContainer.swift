import Foundation

@MainActor
final class DIContainer {
    static let shared = DIContainer()
    private init() {}

    #if DEBUG
    let authUseCase = AuthUseCase(repository: MockAPIService.shared)
    let chatsUseCase = ChatsUseCase(repository: MockAPIService.shared)
    let messagesUseCase = MessagesUseCase(repository: MockAPIService.shared)
    #else
    let authUseCase = AuthUseCase(repository: APIService.shared)
    let chatsUseCase = ChatsUseCase(repository: APIService.shared)
    let messagesUseCase = MessagesUseCase(repository: APIService.shared)
    #endif
}
