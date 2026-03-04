import Foundation

enum APIError: LocalizedError {
    case invalidCredentials
    case networkError
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Неверный логин или пароль"
        case .networkError: return "Ошибка сети, попробуйте позже"
        case .unauthorized: return "Сессия истекла, войдите снова"
        }
    }
}

final class APIService: AuthRepositoryProtocol, ChatRepositoryProtocol {
    static let shared = APIService()
    private init() {}

    private let baseURL = "https://api.lite-chat.example"

    func login(username: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 800_000_000)
        guard username == "demo" && password == "password" else {
            throw APIError.invalidCredentials
        }
        return User(
            id: "usr_001",
            username: "demo",
            displayName: "Demo User",
            token: "mock_jwt_token_abc123"
        )
    }

    func fetchChats(token: String) async throws -> [Chat] {
        try await Task.sleep(nanoseconds: 600_000_000)
        guard token == "mock_jwt_token_abc123" else {
            throw APIError.unauthorized
        }
        let now = Date()
        return [
            Chat(id: "chat_001", name: "Chelovek Odin", avatarInitials: "ЧО",
                 lastMessage: "ЭЭЭЭЭЭЭЭто что такой за текст очень невероятно длинный lorem ipsum dolor sit amet",
                 lastMessageTime: now.addingTimeInterval(-5*60), unreadCount: 2, isOnline: true),
            Chat(id: "chat_002", name: "Chelovek Dva", avatarInitials: "ЧД",
                 lastMessage: "Жесть",
                 lastMessageTime: now.addingTimeInterval(-30*60), unreadCount: 5, isOnline: false),
            Chat(id: "chat_003", name: "Chelovek Tri", avatarInitials: "ЧТ",
                 lastMessage: "Спасибо за помощь!",
                 lastMessageTime: now.addingTimeInterval(-2*60*60), unreadCount: 0, isOnline: true),
            Chat(id: "chat_004", name: "Поддержка", avatarInitials: "🛟",
                 lastMessage: "",
                 lastMessageTime: now.addingTimeInterval(-5*24*60*60), unreadCount: 0, isOnline: false),
        ]
    }
}
