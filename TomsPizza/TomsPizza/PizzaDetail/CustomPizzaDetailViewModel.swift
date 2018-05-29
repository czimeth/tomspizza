import Foundation
import RxSwift
import RxCocoa
import Action
import NotificationBannerSwift

protocol DetailViewModelProtocol {
    var cartService : CartServiceProtocol {get}
    var coordinator : SceneCoordinatorType {get}
    var pizza : ReplaySubject<Pizza> {get}
    var ingredients : ReplaySubject<[Ingredient]> {get set}
    var pizzaDetailPresentables: ReplaySubject<[SectionOfPizzaDetailPresentable]> { get }
    var basePrice : Double { get set }
    func addToCartAction() -> CocoaAction
    func pop()
}

protocol CustomPizzaDetailViewModelProtocol : DetailViewModelProtocol {
    var selectedAction : Action<PizzaDetailPresentable, Void> {get set}
}

final class CustomPizzaDetailViewModel : CustomPizzaDetailViewModelProtocol {
    var pizza = ReplaySubject<Pizza>.create(bufferSize: 1)
    var ingredients = ReplaySubject<[Ingredient]>.create(bufferSize: 1)
    var cartService: CartServiceProtocol
    var coordinator : SceneCoordinatorType
    var pizzaDetailPresentables = ReplaySubject<[SectionOfPizzaDetailPresentable]>.create(bufferSize: 1)
    var disposeBag = DisposeBag()
    var lastPizza : Pizza?
    var basePrice : Double = 0
    var currentIngredients : [Ingredient]?
    init(coordinator : SceneCoordinatorType, cartService : CartServiceProtocol) {
        self.coordinator = coordinator
        self.cartService = cartService
        self.pizza.withLatestFrom(self.ingredients) { pizza, ingredients in
            self.currentIngredients = ingredients
            return PizzaDetailPresentableFactory.createSectionOfPizzaDetailPresentables(pizza: pizza, ingredients: ingredients) }.bind(to: pizzaDetailPresentables).disposed(by: self.disposeBag)
        self.pizza.subscribe(onNext: { (pizza) in
            self.lastPizza = pizza
        }).disposed(by: self.disposeBag)
    }
    func addToCartAction() -> CocoaAction {
        return CocoaAction { [weak self] in
            if let pizza = self?.lastPizza, let service = self?.cartService, let coordinator = self?.coordinator, let strongSelf = self {
                let ingredients = self?.currentIngredients?.filter({ (ingredient) -> Bool in
                    return pizza.ingredients.contains(ingredient.id)
                }).map({ (ingredient) -> Double in
                    return ingredient.price }) ?? []
                let price = ingredients.reduce(0, +) + (self?.basePrice ?? 0)
                return service.addToCart(pizza: pizza, price : price).concat(coordinator.pop()).concat(strongSelf.showBanner()).asObservable().map { _ in  }
            }
            return Observable.empty()
        }
    }
    lazy var selectedAction: Action<PizzaDetailPresentable, Void> = Action<PizzaDetailPresentable, Void> { (item) -> Observable<Void> in
        return Observable<Void>.create({ (observable) -> Disposable in
            if var pizza = self.lastPizza {
                if let index = pizza.ingredients.index(of: item.id) {
                    pizza.ingredients.remove(at: index)
                } else {
                    pizza.ingredients.append(item.id)
                }
                self.pizza.onNext(pizza)
            }
            observable.onCompleted()
            return Disposables.create()
        })
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
    func pop() {
        self.coordinator.updateCurrentViewController()
    }
}
