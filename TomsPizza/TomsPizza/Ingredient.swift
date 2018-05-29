import Foundation

struct Ingredient : Encodable {
    var price: Double
    var id: String
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case price
        case id = "_id"
        case name
    }
}
extension Ingredient : Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        price  = try container.decode(Double.self, forKey: .price)
        do {
            id = String(describing: try container.decode(Int.self, forKey: .id))
        } catch {
            id = try container.decode(String.self, forKey: .id)
        }
        name = try container.decode(String.self, forKey: .name)
    }
}
