import Foundation

public struct CreateRoomEntity {
    public let roomID: String
    public let userID: String
    
    public init(roomID: String, userID: String) {
        self.roomID = roomID
        self.userID = userID
    }
}