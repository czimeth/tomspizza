import Foundation
import RxSwift
import Action

protocol PizzaListViewModelProtocol {
    var selectedAction: Action<PizzaItemPresentable, Void> {get set}
    var coordinator : SceneCoordinatorType {get}
    var cartService : CartServiceProtocol {get}
    var pizzaPresentables : Observable<[SectionOfPizzaPresentable]> { get }
    func addToCart(item: PizzaItemPresentable) -> CocoaAction
    func showCart() -> CocoaAction
    func showCustomPizza() -> CocoaAction
}
final class PizzaListViewModel : PizzaListViewModelProtocol {
    var cartService: CartServiceProtocol
    var coordinator: SceneCoordinatorType
    var ingredients : [Ingredient]?
    var pizzaResult : PizzaQueryResult?
    var service : EndpointProtocol
    var pizzaPresentables : Observable<[SectionOfPizzaPresentable]> {
        return self.service.getPizzas().flatMap { (result) -> Observable<[Ingredient]?> in
            self.pizzaResult = result
            return self.service.getIngedients()
            }.flatMap { (ingredients) -> Observable<[SectionOfPizzaPresentable]> in
                self.ingredients = ingredients
                return Observable.of(PizzaPresentableFactory.createSectionOfPizzaPresentables(result: self.pizzaResult, ingredients: ingredients))
        }
    }
    init(pizzaService : EndpointProtocol, coordinator : SceneCoordinatorType, cartService: CartServiceProtocol) {
        self.service = pizzaService
        self.coordinator = coordinator
        self.cartService = cartService
    }
    lazy var selectedAction: Action<PizzaItemPresentable, Void> = Action<PizzaItemPresentable, Void> { (item) -> Observable<Void> in
        if let ingredients = self.ingredients, let pizza = self.pizzaResult?.pizzas.first(where: { (pizza) -> Bool in return pizza.id == item.id }), let basePrice = self.pizzaResult?.base_price {
            return self.coordinator.transition(to: Scene.pizzaDetail(pizza: pizza, ingredients: ingredients, basePrice: basePrice), type: .push).asObservable().map{_ in }
        }
        return Observable.empty()
    }
    func addToCart(item: PizzaItemPresentable) -> CocoaAction {
        return CocoaAction {
            if let pizza = self.pizzaResult?.pizzas.first(where: { (pizza) -> Bool in return pizza.id == item.id }) {
                return self.cartService.addToCart(pizza: pizza, price : 2.0).asObservable().map { _ in}
            }
            return Observable.empty()
        }
    }
    func showCart() -> CocoaAction {
        return CocoaAction{
            return self.coordinator.transition(to: .cart, type: .push).asObservable().map { _ in }
        }
    }
    func showCustomPizza() -> CocoaAction {
        return CocoaAction{
            return self.coordinator.transition(to: .custom(ingredients: self.ingredients ?? [], basePrice: self.pizzaResult?.base_price ?? 0.0), type: .push).asObservable().map { _ in }
        }
    }
}
