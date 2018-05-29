import RxDataSources

struct SectionOfPizzaDetailPresentable {
    var items: [PizzaDetailPresentable]
}
extension SectionOfPizzaDetailPresentable : SectionModelType {
    typealias Item = PizzaDetailPresentable
    init(original: SectionOfPizzaDetailPresentable, items: [PizzaDetailPresentable]) {
        self = original
        self.items = items
    }
}
struct PizzaDetailPresentable : PizzaPresentable {
    let checked : Bool
    let name : String
    let price : String
    let id : String
}

