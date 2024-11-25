import Combine
import Foundation

import PhotoGetherDomainInterface

final class StickerBottomSheetViewModel {
    enum Input {
        case emojiTapped(index: IndexPath)
    }
    
    enum Output {
        case emoji(entity: EmojiEntity)
    }
    
    private(set) var emojiList = CurrentValueSubject<[EmojiEntity], Never>([])
    
    private let fetchEmojiListUseCase: FetchEmojiListUseCase
    
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output, Never>()
    
    init(
        fetchEmojiListUseCase: FetchEmojiListUseCase
    ) {
        self.fetchEmojiListUseCase = fetchEmojiListUseCase
        
        self.bind()
    }
    
    private func bind() {
        fetchEmojiListUseCase.execute()
            .sink { [weak self] emojiEntities in
                self?.emojiList.send(emojiEntities)
            }
            .store(in: &cancellables)
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .emojiTapped(let indexPath):
                self?.sendEmoji(by: indexPath)
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    func sendEmoji(by indexPath: IndexPath) {
        let selectedEmoji = emojiList[indexPath.item]
        output.send(.emoji(entity: selectedEmoji))
    }
}
