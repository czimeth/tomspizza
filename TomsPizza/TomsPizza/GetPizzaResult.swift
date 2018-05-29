import Foundation

struct PizzaQueryResult : Codable {
    let pizzas : [Pizza]
    let base_price : Double
}
struct Pizza : Encodable {
    var imageURL : String? = ""
    var ingredients : [String]
    let id: String
    let name : String
}
extension Pizza : Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            var _ingredients = try container.decode([Int].self, forKey: .ingredients)
            ingredients = _ingredients.map({ (item) -> String in return String(describing: item) })
        } catch {
            ingredients = try container.decode([String].self, forKey: .ingredients)
        }
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        imageURL = try? container.decode(String?.self, forKey: .imageURL) ?? ""
    }
}
