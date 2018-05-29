import Foundation
import RxSwift
struct Cart : Codable {
    var items : [CartItem] = []
    var checkOutDate : Date?
    private enum CodingKeys: String, CodingKey {
        case items
        case checkOutDate
    }
    enum CodingError: Error {
        case decoding(String)
    }
    init() {
        
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let items = try? container.decode([CartItem].self, forKey: .items) {
            self.items = items
        } else {
            throw CodingError.decoding("Decoding Error: \(dump(container))")
        }
    }
    func getJSON() -> [String:Any] {
        let pizzas = items.filter { (item) -> Bool in
            if case Product.pizza(_) = item.item {
                return true
            }
            return false
            }
        let pizzasParam = String(data: (try? JSONEncoder().encode(pizzas)) ?? Data(), encoding: .utf8)
        let drinks = items.filter { (item) -> Bool in
            if case Product.drink(_) = item.item {
                return true
            }
            return false
        }
        let drinksParam = String(data: (try? JSONEncoder().encode(drinks)) ?? Data(), encoding: .utf8)
        return ["pizzas": pizzasParam ?? [], "drinks" : drinksParam ?? []]
    }
}
enum Product : Codable {
    private enum CodingKeys: String, CodingKey {
        case drink
        case pizza
    }
    enum CodingError: Error {
        case decoding(String)
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let drink = try? container.decode(Drink.self) {
            self = .drink(drink: drink)
            return
        }
        
        if let pizza = try? container.decode(Pizza.self) {
            self = .pizza(pizza: pizza)
            return
        }
        throw CodingError.decoding("Decoding Error: \(dump(container))")
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .drink(let drink):
            try container.encode(drink)
        case .pizza(let pizza):
            try container.encode(pizza)
        }
    }
    case drink(drink : Drink)
    case pizza(pizza : Pizza)
    
    var itemId : String? {
        switch self {
        case .drink(let drink):
            return drink.id
        case .pizza(let pizza):
            return pizza.id
        }
    }
    
    var name : String? {
        switch self {
        case .drink(let drink):
            return drink.name
        case .pizza(let pizza):
            return pizza.name
        }
    }
}
struct CartItem : Codable {
    let item : Product
    let price : Double
    let count : Int
    
    private enum CodingKeys: String, CodingKey {
        case item
        case count
        case price
    }
    enum CodingError: Error {
        case decoding(String)
    }
    init(item : Product, count : Int, price : Double) {
        self.item = item
        self.count = count
        self.price = price
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let count = try? container.decode(Int.self, forKey: .count), let item = try? container.decode(Product.self, forKey: .item), let price = try? container.decode(Double.self, forKey: .price) {
            self.item = item
            self.count = count
            self.price = price
        } else {
            throw CodingError.decoding("Decoding Error: \(dump(container))")
        }

    }
}
protocol CartServiceProtocol : class {
    func addToCart(pizza : Pizza, price : Double) -> Completable
    func addToCart(drink : Drink, price : Double) -> Completable
    func removeFromCart(id:String) -> Completable
    func getCartFromDefaults() -> Observable<Cart>
    func deleteCart() -> Completable
}
final class CartService : CartServiceProtocol {
    static let userDefaultsKey = "Cart"
    let disposeBag = DisposeBag()
    func addToCart(pizza: Pizza, price : Double) -> Completable {
        let subject = PublishSubject<Void>()
        getCartFromDefaults().flatMap { cart -> Observable<Cart> in
            var newCart = cart
            newCart.items.append(CartItem(item: Product.pizza(pizza: pizza), count: 1, price : price))
            return Observable.of(newCart) }.flatMap { self.setCart(cart: $0) }.subscribe(onError: { (error) in
                subject.onError(error)
            }, onCompleted: {
                subject.onCompleted()
        }).disposed(by: self.disposeBag)
        return subject.asObservable().take(1).ignoreElements()
    }
    func removeFromCart(id:String) -> Completable {
        let subject = PublishSubject<Void>()
        getCartFromDefaults().flatMap { cart -> Observable<Cart> in
            var newCart = cart
            if let index = cart.items.index(where: { (pz) -> Bool in return pz.item.itemId == id }) {
                newCart.items.remove(at: index)
            }
            return Observable.of(newCart) }.flatMap { self.setCart(cart: $0) }.subscribe(onError: { (error) in
                subject.onError(error)
            }, onCompleted: {
                subject.onCompleted()
            }).disposed(by: self.disposeBag)
        return subject.asObservable().take(1).ignoreElements()
    }
    func addToCart(drink: Drink, price : Double) -> Completable {
        let subject = PublishSubject<Void>()
        getCartFromDefaults().flatMap { cart -> Observable<Cart> in
            var newCart = cart
            newCart.items.append(CartItem(item: .drink(drink: drink), count: 1, price : price))
            return Observable.of(newCart) }.flatMap { self.setCart(cart: $0) }.subscribe(onError: { (error) in
                subject.onError(error)
            }, onCompleted: {
                subject.onCompleted()
            }).disposed(by: self.disposeBag)
        return subject.asObservable().take(1).ignoreElements()
    }
    func getCartFromDefaults() -> Observable<Cart> {
        return Observable<Cart>.create({ (observable) -> Disposable in
            if let data = UserDefaults.standard.value(forKeyPath: CartService.userDefaultsKey) as? Data, let cart = try? JSONDecoder().decode(Cart.self, from: data) {
                 observable.onNext(cart)
                 observable.onCompleted()
            } else {
                observable.onNext(Cart())
                observable.onCompleted()
            }
            return Disposables.create()
        })
    }
    func setCart(cart : Cart) -> Completable {
        if let data = try? JSONEncoder().encode(cart) {
            UserDefaults.standard.set(data, forKey: CartService.userDefaultsKey)
            UserDefaults.standard.synchronize()
            return Completable.empty()
        }
        return Completable.error(CartError())
    }
    func deleteCart() -> Completable {
        return Completable.create(subscribe: { (completable) -> Disposable in
            UserDefaults.standard.set(nil, forKey: CartService.userDefaultsKey)
            UserDefaults.standard.synchronize()
            completable(.completed)
            return Disposables.create()
        })
    }
}
struct CartError : Error {
    
}
