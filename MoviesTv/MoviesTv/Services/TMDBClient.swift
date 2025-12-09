import Foundation

struct TMDBClient {
    var fetchPopularMovies: (Int) async throws -> TMDBResponse<Movie>
    var fetchPopularTVShows: (Int) async throws -> TMDBResponse<TVShow>
}

extension TMDBClient {
    static let live = Self(
        fetchPopularMovies: { page in
            try await request(endpoint: "movie/popular", page: page)
        },
        fetchPopularTVShows: { page in
            try await request(endpoint: "tv/popular", page: page)
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
}

enum TMDBError: Error {
    case missingConfiguration
    case invalidURL
    case httpError
}
