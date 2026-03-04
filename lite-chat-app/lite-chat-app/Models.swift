import Foundation

struct User: Codable {
    let id: String
    let username: String
    let displayName: String
    let token: String
}

struct Chat: Codable, Identifiable {
    let id: String
    let name: String
    let avatarInitials: String
    let lastMessage: String
    let lastMessageTime: Date
    let unreadCount: Int
    let isOnline: Bool
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let user: User
}
