import UIKit
import PhotoGetherNetwork
import PhotoGetherData
import PhotoGetherDomainInterface
import PhotoGetherDomain
import WaitingRoomFeature
import PhotoRoomFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let urlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
        let url = URL(string: urlString)!
        debugPrint("SignalingServer URL: \(url)")
        
        let webScoketClient: WebSocketClient = WebSocketClientImpl(url: url)
        
        let roomService: RoomService = RoomServiceImpl(
            webSocketClient: webScoketClient
        )
        
        let signalingService: SignalingService = SignalingServiceImpl(
            webSocketClient: webScoketClient
        )
        
        let webRTCService: WebRTCService = WebRTCServiceImpl(
            iceServers: [
                "stun:stun.l.google.com:19302",
                "stun:stun1.l.google.com:19302",
                "stun:stun2.l.google.com:19302",
                "stun:stun3.l.google.com:19302",
                "stun:stun4.l.google.com:19302"
            ]
        )
        
        let connectionClient: ConnectionClient = ConnectionClientImpl(
            signalingService: signalingService,
            webRTCService: webRTCService
        )

        let connectionRepository: ConnectionRepository = ConnectionRepositoryImpl(
            clients: [connectionClient]
        )
        
        let sendOfferUseCase: SendOfferUseCase = SendOfferUseCaseImpl(
            repository: connectionRepository
        )

        let getLocalVideoUseCase: GetLocalVideoUseCase = GetLocalVideoUseCaseImpl(
            connectionRepository: connectionRepository
        )
        
        let getRemoteVideoUseCase: GetRemoteVideoUseCase = GetRemoteVideoUseCaseImpl(
            connectionRepository: connectionRepository
        )
        
        let captureVideosUseCase: CaptureVideosUseCase = CaptureVideosUseCaseImpl(
            connectionRepository: connectionRepository
        )
        
        let photoRoomViewModel: PhotoRoomViewModel = PhotoRoomViewModel(
            captureVideosUseCase: captureVideosUseCase
        )
        
        let photoRoomViewController: PhotoRoomViewController = PhotoRoomViewController(
            connectionRepsitory: connectionRepository,
            viewModel: photoRoomViewModel,
            isHost: true
        )
        
        let viewModel: WaitingRoomViewModel = WaitingRoomViewModel(
            sendOfferUseCase: sendOfferUseCase,
            getLocalVideoUseCase: getLocalVideoUseCase,
            getRemoteVideoUseCase: getRemoteVideoUseCase
        )
        
        let viewController: WaitingRoomViewController = WaitingRoomViewController(
            viewModel: viewModel,
            photoRoomViewController: photoRoomViewController
        )
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: viewController)
        window?.makeKeyAndVisible()
    }
}
