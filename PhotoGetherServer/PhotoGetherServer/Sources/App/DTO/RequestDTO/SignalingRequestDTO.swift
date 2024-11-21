import Foundation

struct SignalingRequestDTO: WebSocketRequestable {
    var messageType: SignalingMessageType
    var message: Data?
    
    init(messageType: SignalingMessageType = .signaling, body: Data? = nil) {
        self.messageType = messageType
    }
    
    enum SignalingMessageType: String, Decodable {
        case signaling
    }
}
