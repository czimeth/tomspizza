import UIKit
import Swinject
import SwinjectStoryboard

enum Scene {
    case pizzaList
    case pizzaDetail(pizza : Pizza, ingredients : [Ingredient], basePrice : Double)
    case cart
    case custom(ingredients: [Ingredient], basePrice : Double)
    case drinks
    case thankyou
}

extension Scene {
    func viewController() -> UIViewController {
        let storyboard = SwinjectStoryboard.create(name: "Main", bundle: nil, container: SwinjectStoryboard.defaultContainer)
        switch self {
        case .pizzaList:
            let nc = storyboard.instantiateInitialViewController()
            return nc!
        case .pizzaDetail(let pizza,let ingredients, let basePrice):
            let vc = storyboard.instantiateViewController(ofType: CustomPizzaViewController.self)
            vc.viewModel?.ingredients.onNext(ingredients)
            vc.viewModel?.basePrice = basePrice
            vc.viewModel?.pizza.onNext(pizza)
            return vc
        case .cart:
            let vc = storyboard.instantiateViewController(ofType: CartViewController.self)
            return vc
        case .custom(let ingredients, let basePrice):
            let vc = storyboard.instantiateViewController(ofType: CustomPizzaViewController.self)
            vc.viewModel?.ingredients.onNext(ingredients)
            vc.viewModel?.basePrice = basePrice
            vc.viewModel?.pizza.onNext(Pizza(imageURL: "", ingredients: [], id: UUID.init().uuidString, name: "Custom pizza"))
            return vc
        case .drinks:
            let vc = storyboard.instantiateViewController(ofType: DrinksViewController.self)
            return vc
        case .thankyou:
            let vc = storyboard.instantiateViewController(ofType: ThankYouViewController.self)
            return vc
        }
    }
}
