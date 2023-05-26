import Foundation

struct URLProvider {
    enum Error: Swift.Error {
        case invalidURL
    }
    
    private let host: String
    private let scheme: String = "https"
    
    init(host: String) {
        self.host = host
    }
    
    var transactions: URL { get throws { try url(forPath: "/transactions") }}
    
    private func url(forPath path: String) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        guard let url = urlComponents.url else {
            throw Error.invalidURL
        }
        return url
    }
}


