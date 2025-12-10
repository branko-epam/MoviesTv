import Foundation

struct TMDBClient {
    var fetchPopularMovies: (Int) async throws -> TMDBResponse<Movie>
    var fetchPopularTVShows: (Int) async throws -> TMDBResponse<TVShow>
    var searchKeyword: (String, Int) async throws -> TMDBResponse<SearchKeyword>
    var discoverMovies: (Int, Int) async throws -> TMDBResponse<Movie>
    var discoverTVShows: (Int, Int) async throws -> TMDBResponse<TVShow>
    var fetchMovieCredits: (Int) async throws -> CreditsResponse
    var fetchTVShowCredits: (Int) async throws -> CreditsResponse
}

extension TMDBClient {
    static let live = Self(
        fetchPopularMovies: { page in
            try await request(endpoint: "movie/popular", page: page)
        },
        fetchPopularTVShows: { page in
            try await request(endpoint: "tv/popular", page: page)
        },
        searchKeyword: { query, page in
            try await searchRequest(endpoint: "search/keyword", query: query, page: page)
        },
        discoverMovies: { keywordId, page in
            try await discoverRequest(endpoint: "discover/movie", keywordId: keywordId, page: page)
        },
        discoverTVShows: { keywordId, page in
            try await discoverRequest(endpoint: "discover/tv", keywordId: keywordId, page: page)
        },
        fetchMovieCredits: { movieId in
            try await creditsRequest(endpoint: "movie/\(movieId)/credits")
        },
        fetchTVShowCredits: { tvShowId in
            try await creditsRequest(endpoint: "tv/\(tvShowId)/credits")
        }
    )

    private static func request<T: Decodable>(endpoint: String, page: Int) async throws -> T {
        guard let baseUrl = Bundle.main.infoDictionary?["MDB_BASE_URL"] as? String,
              let token = Bundle.main.infoDictionary?["MDB_READ_API_KEY"] as? String else {
            throw TMDBError.missingConfiguration
        }

        guard !token.isEmpty else {
            throw TMDBError.missingConfiguration
        }
        
        guard let url = URL(string: "\(baseUrl)/\(endpoint)") else {
            throw TMDBError.invalidURL
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TMDBError.httpError
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    private static func searchRequest<T: Decodable>(endpoint: String, query: String, page: Int) async throws -> T {
        guard let baseUrl = Bundle.main.infoDictionary?["MDB_BASE_URL"] as? String,
              let token = Bundle.main.infoDictionary?["MDB_READ_API_KEY"] as? String else {
            throw TMDBError.missingConfiguration
        }

        guard !token.isEmpty else {
            throw TMDBError.missingConfiguration
        }

        guard let url = URL(string: "\(baseUrl)/\(endpoint)") else {
            throw TMDBError.invalidURL
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TMDBError.httpError
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    private static func discoverRequest<T: Decodable>(endpoint: String, keywordId: Int, page: Int) async throws -> T {
        guard let baseUrl = Bundle.main.infoDictionary?["MDB_BASE_URL"] as? String,
              let token = Bundle.main.infoDictionary?["MDB_READ_API_KEY"] as? String else {
            throw TMDBError.missingConfiguration
        }

        guard !token.isEmpty else {
            throw TMDBError.missingConfiguration
        }

        guard let url = URL(string: "\(baseUrl)/\(endpoint)") else {
            throw TMDBError.invalidURL
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "with_keywords", value: "\(keywordId)")
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TMDBError.httpError
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    private static func creditsRequest(endpoint: String) async throws -> CreditsResponse {
        guard let baseUrl = Bundle.main.infoDictionary?["MDB_BASE_URL"] as? String,
              let token = Bundle.main.infoDictionary?["MDB_READ_API_KEY"] as? String else {
            throw TMDBError.missingConfiguration
        }

        guard !token.isEmpty else {
            throw TMDBError.missingConfiguration
        }

        guard let url = URL(string: "\(baseUrl)/\(endpoint)") else {
            throw TMDBError.invalidURL
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "language", value: "en-US")
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TMDBError.httpError
        }

        return try JSONDecoder().decode(CreditsResponse.self, from: data)
    }
}

enum TMDBError: Error {
    case missingConfiguration
    case invalidURL
    case httpError
}
