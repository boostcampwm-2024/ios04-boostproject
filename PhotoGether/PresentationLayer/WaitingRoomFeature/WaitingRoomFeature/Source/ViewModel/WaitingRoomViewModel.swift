import UIKit
import Combine
import PhotoGetherDomainInterface

public final class WaitingRoomViewModel {
    enum Input {
        case viewDidLoad
        case micMuteButtonDidTap
        case linkButtonDidTap
        case startButtonDidTap
    }
    
    enum Output {
        case localVideo(UIView)
        case remoteVideos([UIView])
        case micMuteState(Bool)
        case shouldShowShareSheet(String)
        case navigateToPhotoRoom
        case shouldShowToast(String)
    }
    
    private let sendOfferUseCase: SendOfferUseCase
    private let getLocalVideoUseCase: GetLocalVideoUseCase
    private let getRemoteVideoUseCase: GetRemoteVideoUseCase
    private let createRoomUseCase: CreateRoomUseCase
    
    private var isHost: Bool
    private var cancellables = Set<AnyCancellable>()
    private let output = PassthroughSubject<Output, Never>()
    
    public init(
        isHost: Bool,
        sendOfferUseCase: SendOfferUseCase,
        getLocalVideoUseCase: GetLocalVideoUseCase,
        getRemoteVideoUseCase: GetRemoteVideoUseCase,
        createRoomUseCase: CreateRoomUseCase
    ) {
        self.isHost = isHost
        self.sendOfferUseCase = sendOfferUseCase
        self.getLocalVideoUseCase = getLocalVideoUseCase
        self.getRemoteVideoUseCase = getRemoteVideoUseCase
        self.createRoomUseCase = createRoomUseCase
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
                self?.handleEvent(event)
            }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func handleEvent(_ event: Input) {
        switch event {
        case .viewDidLoad:
            handleViewDidLoad()
        case .micMuteButtonDidTap:
            output.send(.micMuteState(true)) // 예제에서는 항상 true 반환
        case .linkButtonDidTap:
            handleLinkButtonDidTap()
        case .startButtonDidTap:
            output.send(.navigateToPhotoRoom)
        }
    }
    
    private func handleViewDidLoad() {
        let localVideo = getLocalVideoUseCase.execute()
        output.send(.localVideo(localVideo))
        
        let remoteVideos = getRemoteVideoUseCase.execute()
        output.send(.remoteVideos(remoteVideos))
        
        if !isHost {
            Task {
                do {
                    try await sendOfferUseCase.execute()
                    output.send(.shouldShowToast("연결을 시도합니다."))
                } catch {
                    output.send(.shouldShowToast("연결 중 에러가 발생했어요."))
                }
            }
        }
    }
    
    private func handleLinkButtonDidTap() {
        createRoomUseCase.execute()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    debugPrint(error.localizedDescription)
                    self?.output.send(.shouldShowToast("Failed to create room"))
                }
            }, receiveValue: { [weak self] roomLink in
                self?.output.send(.shouldShowShareSheet(roomLink))
            })
            .store(in: &cancellables)
    }
}
