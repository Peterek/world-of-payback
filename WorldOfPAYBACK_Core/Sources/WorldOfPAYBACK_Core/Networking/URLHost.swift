struct URLHost: RawRepresentable {
    var rawValue: String
}

extension URLHost {
    static var test: Self {
        Self(rawValue: "api-test.payback.com")
    }

    static var production: Self {
        Self(rawValue: "api.payback.com")
    }

    static var `default`: Self {
        #if DEBUG
        return test
        #else
        return production
        #endif
    }
}
