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

struct Message: Codable, Identifiable {
    let id: String
    let senderId: String
    let text: String
    let timestamp: Date
    let updatedAt: Date?

    init(id: String, senderId: String, text: String, timestamp: Date, updatedAt: Date? = nil) {
        self.id = id
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp
        self.updatedAt = updatedAt
    }
}
