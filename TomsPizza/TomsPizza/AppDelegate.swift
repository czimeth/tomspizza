import UIKit
import SwinjectStoryboard
import Swinject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window
        let container = createContainer(window: window)
        let storyboard = SwinjectStoryboard.create(name: "Main", bundle: nil, container: container)
        window.rootViewController = storyboard.instantiateInitialViewController()
        
        return true
    }
    
    private func createContainer(window : UIWindow) -> Container {
        let container = SwinjectStoryboard.defaultContainer
        container.register(SceneCoordinatorType.self, factory: { _ in SceneCoordinator(window: window) }).inObjectScope(.container)
        container.register(CartServiceProtocol.self, factory: { _ in CartService() })
        container.storyboardInitCompleted(PizzaListViewController.self) { r, c in
            c.viewModel = r.resolve(PizzaListViewModelProtocol.self)
        }
        
        container.register(PizzaListViewModelProtocol.self) { r in PizzaListViewModel(pizzaService: r.resolve(EndpointProtocol.self)!, coordinator: r.resolve(SceneCoordinatorType.self)!,cartService: r.resolve(CartServiceProtocol.self)!) }
        container.register(EndpointProtocol.self, factory: { _ in TomsPizzaEndpoint() })
        
        container.storyboardInitCompleted(CustomPizzaViewController.self) { (r, c) in
            c.viewModel = r.resolve(CustomPizzaDetailViewModelProtocol.self)
        }
        container.storyboardInitCompleted(CartViewController.self) { (r, c) in
            c.viewModel = r.resolve(CartViewModelProtocol.self)
        }
        container.storyboardInitCompleted(DrinksViewController.self) { r, c in
            c.viewModel = r.resolve(DrinksViewModelProtocol.self)
        }
        container.storyboardInitCompleted(ThankYouViewController.self) { (r, c) in
            c.coordinator = r.resolve(SceneCoordinatorType.self)
        }
        container.register(CartViewModelProtocol.self) { r in CartViewModel(service: r.resolve(EndpointProtocol.self)!, cartService: r.resolve(CartServiceProtocol.self)!, coordinator: r.resolve(SceneCoordinatorType.self)!)
        }
        container.register(CustomPizzaDetailViewModelProtocol.self) { r in CustomPizzaDetailViewModel(coordinator: r.resolve(SceneCoordinatorType.self)!, cartService: r.resolve(CartServiceProtocol.self)!) }
        container.register(DrinksViewModelProtocol.self) { r in DrinksViewModel(service: r.resolve(EndpointProtocol.self)!, cartService: r.resolve(CartServiceProtocol.self)!, coordinator: r.resolve(SceneCoordinatorType.self)!) }
        return container
    }
}

