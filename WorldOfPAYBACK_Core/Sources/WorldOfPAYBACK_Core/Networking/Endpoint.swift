import Foundation

protocol DataDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONDecoder: DataDecoder {}

struct Endpoint<Response: Decodable> {
    var path: String
    var queryItems = [URLQueryItem]()
    var decoder: DataDecoder = JSONDecoder()
}

extension Endpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = URLHost.default.rawValue
        components.path = "/" + path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        return url
    }
    
    var request: URLRequest {
        URLRequest(url: url)
    }
}
