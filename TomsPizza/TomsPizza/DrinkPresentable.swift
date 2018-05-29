import RxDataSources

protocol DrinkPresentable {

}
struct SectionOfDrinkPresentable {
    var items: [DrinkPresentable]
}
extension SectionOfDrinkPresentable: SectionModelType {
    typealias Item = DrinkPresentable
    init(original: SectionOfDrinkPresentable, items: [DrinkPresentable]) {
        self = original
        self.items = items
    }
}
extension Drink : DrinkPresentable {
}
