import RxDataSources

protocol CartPresentable {
}
struct SectionOfCartItemPresentable {
    var items: [CartPresentable]
}
extension SectionOfCartItemPresentable: SectionModelType {
    typealias Item = CartPresentable
    init(original: SectionOfCartItemPresentable, items: [CartPresentable]) {
        self = original
        self.items = items
    }
}
struct CartItemPresentable : CartPresentable {
    let id : String
    let name : String
    let price : String
    
    init? (id : String?, name : String?, price : String?){
        guard let id = id, let name = name, let price = price else {
            return nil
        }
        self.id = id
        self.name = name
        self.price = price
    }
}
struct TotalPresentable : CartPresentable {
    let price : String
    
    init (price : String){
        self.price = price
    }
}
