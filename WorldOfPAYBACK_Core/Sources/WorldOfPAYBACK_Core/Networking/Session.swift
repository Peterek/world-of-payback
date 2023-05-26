import Foundation

protocol Session {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: Session {}

extension Session {
    func request<Response>(_ endpoint: Endpoint<Response>) async throws -> Response {
        let (data, _) = try await data(for: endpoint.request)
        let decodedResponse = try endpoint.decoder.decode(Response.self, from: data)
        return decodedResponse
    }
}
