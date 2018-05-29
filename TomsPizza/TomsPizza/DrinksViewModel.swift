import Foundation
import RxSwift
import RxCocoa
import Action
import NotificationBannerSwift

protocol DrinksViewModelProtocol {
    var cartService : CartServiceProtocol? {get set}
    var drinkPresentables : ReplaySubject<[SectionOfDrinkPresentable]> { get set }
    func pop()
    func addItemToCart(id : String) -> CocoaAction
}

final class DrinksViewModel : DrinksViewModelProtocol {
    var coordinator : SceneCoordinatorType?
    var cartService : CartServiceProtocol?
    var service : EndpointProtocol?
    var drinkPresentables = ReplaySubject<[SectionOfDrinkPresentable]>.create(bufferSize: 1)
    var drinks : [Drink]?
    var disposeBag = DisposeBag()
    
    init(service : EndpointProtocol, cartService : CartServiceProtocol, coordinator : SceneCoordinatorType) {
        self.cartService = cartService
        self.service = service
        self.coordinator = coordinator
        service.getDrinks().flatMap { (drinks) -> Observable<[SectionOfDrinkPresentable]> in
            self.drinks = drinks
            return Observable.of([SectionOfDrinkPresentable(items: drinks ?? [])])
        }.bind(to: self.drinkPresentables).disposed(by: self.disposeBag)
    }
    func pop() {
        self.coordinator?.updateCurrentViewController()
    }
    func addItemToCart(id : String) -> CocoaAction {
        return CocoaAction { [weak self] in
            if let service = self?.cartService, let drink = self?.drinks?.first(where: { (drink) -> Bool in return drink.id == id }), let coordinator = self?.coordinator, let strongSelf = self {
                return service.addToCart(drink: drink, price: drink.price).concat(coordinator.pop()).concat(strongSelf.showBanner()).asObservable().map { _ in  }
            }
            return Observable.empty()
        }
    }
    func showBanner() -> Completable {
        return Completable.create(subscribe: { (completable) -> Disposable in
            let banner = NotificationBanner(customView: NotificationView())
            banner.duration = 3.0
            banner.show()
            completable(.completed)
            return Disposables.create()
        })
    }
}
