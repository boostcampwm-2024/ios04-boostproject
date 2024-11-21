import Foundation

public struct EmojiEntity: Decodable {
    public let image: String
    public let name: String

    public init(image: String, name: String) {
        self.image = image
        self.name = name
    }
}