import Foundation

final class CartItemPresentableFactory {
    static func createCartItemPresetnables(cart : Cart) -> [SectionOfCartItemPresentable] {
        let items = cart.items.compactMap({ (item) -> CartItemPresentable? in
            return CartItemPresentable(id : item.item.itemId, name : item.item.name, price: String(describing : item.price))
        })
        let total = cart.items.map { (item) -> Double in
            return item.price
        }.reduce(0, +)
        let presentable = TotalPresentable(price: String(describing: total ?? 0))
        return [SectionOfCartItemPresentable(items: items), SectionOfCartItemPresentable(items:[presentable])]
    }
}
