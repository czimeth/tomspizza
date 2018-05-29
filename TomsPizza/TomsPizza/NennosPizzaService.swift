import Foundation
import Moya

enum TomsPizzaService {
    case getPizzas
    case getDrinks
    case getIngredients
    case postCheckout(cart : Cart)
}

extension TomsPizzaService : TargetType {
    static let baseURLString  = "http://www.json-generator.com/api/json/get/"
    static let postURLString = "http://ptsv2.com/t/qad8f-1526231863/post"
    var baseURL: URL {
        switch self {
        case .postCheckout:
            return URL(string: TomsPizzaService.postURLString)!
        default:
            return URL(string: TomsPizzaService.baseURLString)!
        }
    }
    var path: String {
        switch self {
        case .getPizzas:
            return "cpvhHylqgi"
        case .getDrinks:
            return "cerzYAAmHm"
        case .getIngredients:
            return "bOqSsyyajS"
        case .postCheckout:
            return ""
        }
    }
    var method: Moya.Method {
        switch self {
        case .getPizzas:
            return .get
        case .getDrinks:
            return .get
        case .getIngredients:
            return .get
        case .postCheckout:
            return .post
        }
    }
    var task: Task {
        switch self {
        case .getPizzas:
            return .requestParameters(parameters: parameters ?? [String:Any](), encoding: parameterEncoding)
        case .getDrinks:
            return .requestParameters(parameters: parameters ?? [String:Any](), encoding: parameterEncoding)
        case .getIngredients:
            return .requestParameters(parameters: parameters ?? [String:Any](), encoding: parameterEncoding)
        case .postCheckout( _):
            return .requestCompositeParameters(bodyParameters: parameters ?? [String:Any](), bodyEncoding: parameterEncoding, urlParameters: [String:Any]())
        }
    }
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .getPizzas:
            return URLEncoding.default
        case .getDrinks:
            return URLEncoding.default
        case .getIngredients:
            return URLEncoding.default
        case .postCheckout:
            return JSONEncoding.default
        }
    }
    var parameters: [String : Any]? {
        switch self {
        case .postCheckout(let cart):
            return cart.getJSON()
        default:
            return nil
        }
    }
    var validate: Bool {
        switch self {
        default:
            return false
        }
    }
    var headers : [String: String]? {
        return ["Content-type": "application/x-www-form-urlencoded"]
    }
    var sampleData: Data {
        switch self {
        default:
            return "".utf8Encoded
        }
    }
}

extension String {
    public var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    public var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}

