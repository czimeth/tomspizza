import Foundation

struct Drink : Codable {
    var id : String
    var price: Double
    var name: String 
    
    enum CodingKeys : String, CodingKey {
        case price
        case id = "_id"
        case name
    }
}
