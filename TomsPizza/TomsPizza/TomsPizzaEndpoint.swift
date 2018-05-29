import Foundation
import Moya
import RxSwift

protocol EndpointProtocol {
    func getPizzas() -> Observable<PizzaQueryResult?>
    func getDrinks() -> Observable<[Drink]?>
    func getIngedients() -> Observable<[Ingredient]?>
    func post(cart : Cart) -> Completable
}
struct TomsPizzaEndpoint : EndpointProtocol {
    let provider = MoyaProvider<TomsPizzaService>()
    
    func getPizzas() -> Observable<PizzaQueryResult?> {
        return self.provider.rx.request(.getPizzas)
            .filter(statusCodes: 200...304).map({ result -> PizzaQueryResult? in
                return try JSONDecoder().decode([PizzaQueryResult].self, from: result.data).first
            }).asObservable()
    }
    func getDrinks() -> Observable<[Drink]?> {
        return self.provider.rx.request(.getDrinks)
            .filter(statusCodes: 200...304).map({ result -> [Drink]? in
                return try JSONDecoder().decode([Drink].self, from: result.data)
            }).asObservable()
    }
    func getIngedients() -> Observable<[Ingredient]?> {
        return self.provider.rx.request(.getIngredients)
            .filter(statusCodes: 200...304).map({ result -> [Ingredient]? in
                return try JSONDecoder().decode([Ingredient].self, from: result.data)
            }).asObservable()
    }
    func post(cart: Cart) -> Completable {
        return self.provider.rx.request(.postCheckout(cart: cart)).filter(statusCodes: 200...304).flatMapToCompletable()
    }
}

extension PrimitiveSequenceType where Self.TraitType == RxSwift.SingleTrait {
    func flatMapToCompletable() -> Completable {
        return Completable.create { completable -> Disposable in
            return self.subscribe(onSuccess: { _ in
                completable(.completed)
            }, onError: { error in
                completable(.error(error))
            })
        }
    }
}
