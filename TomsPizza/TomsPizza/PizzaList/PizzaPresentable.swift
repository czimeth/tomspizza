import RxDataSources

protocol PizzaPresentable {
}
struct SectionOfPizzaPresentable {
    var items: [PizzaPresentable]
}
extension SectionOfPizzaPresentable: SectionModelType {
    typealias Item = PizzaPresentable
    init(original: SectionOfPizzaPresentable, items: [PizzaPresentable]) {
        self = original
        self.items = items
    }
}
struct PizzaItemPresentable : PizzaPresentable {
    let id : String
    let name : String
    let imagURL : String
    let ingredients : String
    let price : String
}
