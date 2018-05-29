import Foundation
import Action
import RxSwift

protocol CartViewModelProtocol {
    var cartPresentables : Variable<[SectionOfCartItemPresentable]> {get set}
    var coordinator : SceneCoordinatorType {get}
    var cartService : CartServiceProtocol {get}
    func bindData()
    func removeFromCart(item: CartItemPresentable) -> CocoaAction
    func routeToDrinks() -> CocoaAction
    func postCart() -> CocoaAction
    func pop()
}

final class CartViewModel : CartViewModelProtocol {
    var cartPresentables = Variable<[SectionOfCartItemPresentable]>([])
    var coordinator: SceneCoordinatorType
    var cartService: CartServiceProtocol
    var service : EndpointProtocol
    var disposeBag = DisposeBag()
    var cart : Cart?
    init(service : EndpointProtocol, cartService: CartServiceProtocol, coordinator : SceneCoordinatorType) {
        self.cartService = cartService
        self.coordinator = coordinator
        self.service = service
        bindData()
    }
    func bindData() {
        UserDefaults.standard.rx.observe(Data.self, "Cart").map { (data) -> [SectionOfCartItemPresentable] in
            if let cart = data, let decodedCart = try? JSONDecoder().decode(Cart.self, from: cart) {
                self.cart = decodedCart
                return CartItemPresentableFactory.createCartItemPresetnables(cart: decodedCart)
            } else {
                return CartItemPresentableFactory.createCartItemPresetnables(cart: Cart())
            }
        }.debounce(0.2, scheduler: MainScheduler.instance).bind(to: self.cartPresentables).disposed(by: self.disposeBag)
    }
    func removeFromCart(item: CartItemPresentable) -> CocoaAction {
        return CocoaAction{
            return self.cartService.removeFromCart(id: item.id).asObservable().map { _ in }
        }
    }
    func presentDrinks() -> CocoaAction {
        return CocoaAction {
            return self.coordinator.transition(to: .drinks, type: .push).asObservable().map { _ in }
        }
    }
    func pop() {
        self.coordinator.updateCurrentViewController()
    }
    func routeToDrinks() -> CocoaAction {
        return CocoaAction{
            return self.coordinator.transition(to: .drinks, type: .push).asObservable().map { _ in }
        }
    }
    func postCart() -> CocoaAction {
        return CocoaAction {
            if let cart = self.cart {
                return self.service.post(cart: cart).concat(self.cartService.deleteCart()).concat(self.coordinator.transition(to: .thankyou, type: .push)).asObservable().map { _ in }
            }
            return Completable.empty().asObservable().map { _ in }
        }
    }
}

