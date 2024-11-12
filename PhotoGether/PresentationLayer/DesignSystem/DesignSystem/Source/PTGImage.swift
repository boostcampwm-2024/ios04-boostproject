import UIKit

public enum PTGImage {
    case frameIcon
    case stickerIcon
    case chevronLeftWhite
    case chevronRightBlack
    
    public var image: UIImage {
        switch self {
        case .frameIcon:
            return UIImage(resource: .frameIcon)
        case .stickerIcon:
            return UIImage(resource: .stickerIcon)
        case .chevronLeftWhite:
            return UIImage(resource: .chevronLeftWhite)
        case .chevronRightBlack:
            return UIImage(resource: .chevronRightBlack)
        }
    }
}