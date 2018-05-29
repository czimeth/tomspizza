import Foundation

final class PizzaDetailPresentableFactory {
    static func createSectionOfPizzaDetailPresentables(pizza:Pizza?, ingredients : [Ingredient]?)->[SectionOfPizzaDetailPresentable] {
        let items = ingredients?.map({ (ingredient) -> PizzaDetailPresentable in
            return PizzaDetailPresentable(checked: (pizza?.ingredients.contains(ingredient.id) ?? false), name: ingredient.name, price: String(describing: ingredient.price) + "$", id: ingredient.id)
        })
        let section = SectionOfPizzaDetailPresentable(items: items ?? [])
        return [section]
    }
}
