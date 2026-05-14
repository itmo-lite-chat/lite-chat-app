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

final class MockAPIService: AuthRepositoryProtocol, ChatRepositoryProtocol, MessageRepositoryProtocol {
    static let shared = MockAPIService()
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

    func fetchMessages(chatId: String, token: String) async throws -> [Message] {
        try await Task.sleep(nanoseconds: 400_000_000)
        guard token == "mock_jwt_token_abc123" else { throw APIError.unauthorized }

        let now = Date()
        let other = "other_001"
        let me = "usr_001"

        let history: [Message] = [
            Message(id: "\(chatId)_1", senderId: other, text: "Привет!", timestamp: now.addingTimeInterval(-3600)),
            Message(id: "\(chatId)_2", senderId: me,    text: "Привет, как дела?", timestamp: now.addingTimeInterval(-3540)),
            Message(id: "\(chatId)_3", senderId: other, text: "Всё хорошо, спасибо. Ты уже посмотрел задачу?", timestamp: now.addingTimeInterval(-3480)),
            Message(id: "\(chatId)_4", senderId: me,    text: "Да, сейчас занимаюсь", timestamp: now.addingTimeInterval(-3400)),
            Message(id: "\(chatId)_5", senderId: other, text: "Окей, жду", timestamp: now.addingTimeInterval(-3300)),
        ]
        return history
    }

    func sendMessage(chatId: String, text: String, token: String) async throws -> Message {
        try await Task.sleep(nanoseconds: 200_000_000)
        guard token == "mock_jwt_token_abc123" else { throw APIError.unauthorized }
        return Message(id: UUID().uuidString, senderId: "usr_001", text: text, timestamp: Date())
    }
}
