import Foundation

final class PizzaPresentableFactory {
    static func createSectionOfPizzaPresentables(result:PizzaQueryResult?, ingredients : [Ingredient]?)->[SectionOfPizzaPresentable] {
        let basePrice = result?.base_price ?? 0
        let pizzaPresentables = result?.pizzas.map({ (pizza) -> PizzaPresentable in
            let ingredients = ingredients?.filter({ (ingredient) -> Bool in return pizza.ingredients.contains(ingredient.id)})
            let ingredientNames = ingredients?.map({ (ing) -> String in return ing.name + "," }).compactMap({$0}).joined()
            var sumOfPrices = ingredients?.map({ (ing) -> Double in return ing.price }).reduce(0, +) ?? 0
            sumOfPrices = sumOfPrices + basePrice
            return PizzaItemPresentable(id: pizza.id, name: pizza.name, imagURL: pizza.imageURL ?? "", ingredients: ingredientNames ?? "", price: String(describing: sumOfPrices) + "$")
        })
        let section = SectionOfPizzaPresentable(items: pizzaPresentables ?? [])
        return [section]
    }
}
