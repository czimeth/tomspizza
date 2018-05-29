import Foundation
import RxSwift
import RxCocoa
import SwinjectStoryboard
import Swinject

protocol SceneCoordinatorType {
    init(window: UIWindow)
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable
    @discardableResult
    func pop(animated: Bool)  -> Completable
    func updateCurrentViewController()
}

extension SceneCoordinatorType {
    @discardableResult
    func pop() -> Completable {
        return pop(animated: true)
    }
}


class SceneCoordinator: SceneCoordinatorType {
    
    fileprivate var window: UIWindow
    fileprivate var currentViewController: UIViewController = UIViewController()
    let disposeBag = DisposeBag()
    required init(window: UIWindow) {
        self.window = window
        window.rx.observe(UIViewController.self, "rootViewController", options: KeyValueObservingOptions.new, retainSelf: true).take(1).subscribe({ (event) in
            if let vc = event.element as? UIViewController {
                self.currentViewController = vc
            }
        }).disposed(by: self.disposeBag)
    }
    func updateCurrentViewController() {
        if let navigationController = currentViewController.navigationController {
            if let topVC = navigationController.topViewController {
                self.currentViewController = topVC
            }
        }
    }
    static func actualViewController(for viewController: UIViewController) -> UIViewController {
        if let navigationController = viewController as? UINavigationController {
            return navigationController.viewControllers.first!
        } else {
            return viewController
        }
    }
    
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable  {
        let subject = PublishSubject<Void>()
        let viewController = scene.viewController()
        switch type {
        case .root:
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            window.rootViewController = viewController
            subject.onCompleted()
            
        case .push:
            guard let navigationController = SceneCoordinator.actualNavController(for: currentViewController) else {
                fatalError("Can't push a view controller without a current navigation controller")
            }
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            navigationController.pushViewController(viewController, animated: true)
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            
        case .modal:
            currentViewController.present(viewController, animated: true) {
                subject.onCompleted()
            }
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
        }
        return subject.asObservable().take(1).ignoreElements()
    }
    
    @discardableResult
    func pop(animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
        if let presenter = currentViewController.presentingViewController {
            currentViewController.dismiss(animated: animated) {
                self.currentViewController = SceneCoordinator.actualViewController(for: presenter)
                subject.onCompleted()
            }
        } else if let navigationController = SceneCoordinator.actualNavController(for: currentViewController) {
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            guard navigationController.popViewController(animated: animated) != nil else {
                fatalError("can't navigate back from \(currentViewController)")
            }
            currentViewController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
        } else {
            fatalError("Not a modal, no navigation controller: can't navigate back from \(currentViewController)")
        }
        return subject.asObservable().take(1).ignoreElements()
    }
    
    private static func actualNavController(for viewController : UIViewController) -> UINavigationController? {
        return SceneCoordinator.actualViewController(for: viewController).navigationController
    }
}

enum SceneTransitionType {
    case root
    case push
    case modal
}

