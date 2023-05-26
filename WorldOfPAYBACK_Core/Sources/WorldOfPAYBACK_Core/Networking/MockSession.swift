import Foundation

struct MockSession: Session {
    enum Error: Swift.Error {
        case fake
        case missingFile
        case corruptedData
        case responseInitError
    }
    
    private let resources: [URLRequest: String] = [Endpoint.transactions.request: "PBTransactions.json"]
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await Task.sleep(for: .seconds(Int.random(in: 1...2)))
        if Int.random(in: 1...3) == 1 {
            throw Error.fake
        }
        guard let url = Bundle.module.url(forResource: resources[request], withExtension: nil) else {
            throw Error.missingFile
        }
        guard let data = try? Data(contentsOf: url) else {
            throw Error.corruptedData
        }
        guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
            throw Error.responseInitError
        }
        return (data, response)
    }
}
