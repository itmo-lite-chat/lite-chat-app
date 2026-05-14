import Foundation

struct LoginRequest: Encodable {
    let username: String
    let password: String
}

struct LoginResponse: Decodable {
    let user: User
}

struct ChatsResponse: Decodable {
    let chats: [Chat]
}

struct PrivateChatRequest: Encodable {
    let username: String
}

struct PrivateChatResponse: Decodable {
    let chat: Chat
}

struct MessagesResponse: Decodable {
    let messages: [Message]
}

struct SendMessageRequest: Encodable {
    let body: String
}

struct SendMessageResponse: Decodable {
    let message: Message
}

struct EditMessageRequest: Encodable {
    let body: String
}

struct EditMessageResponse: Decodable {
    let message: Message
}

struct ErrorResponse: Decodable {
    let error: String
}
