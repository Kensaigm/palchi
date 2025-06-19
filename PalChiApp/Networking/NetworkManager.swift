import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - URLSession Configuration
    
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        return URLSession(configuration: configuration)
    }()
    
    // MARK: - Generic Request Method
    
    func performRequest<T: Codable>(
        url: URL,
        method: HTTPMethod = .GET,
        headers: [String: String]? = nil,
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }
    
    // MARK: - Convenience Methods
    
    func get<T: Codable>(
        url: URL,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        performRequest(url: url, method: .GET, headers: headers, responseType: responseType, completion: completion)
    }
    
    func post<T: Codable>(
        url: URL,
        headers: [String: String]? = nil,
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        performRequest(url: url, method: .POST, headers: headers, body: body, responseType: responseType, completion: completion)
    }
    
    func put<T: Codable>(
        url: URL,
        headers: [String: String]? = nil,
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        performRequest(url: url, method: .PUT, headers: headers, body: body, responseType: responseType, completion: completion)
    }
    
    func delete<T: Codable>(
        url: URL,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        performRequest(url: url, method: .DELETE, headers: headers, responseType: responseType, completion: completion)
    }
    
    // MARK: - Upload Methods
    
    func uploadData(
        url: URL,
        data: Data,
        headers: [String: String]? = nil,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        urlSession.uploadTask(with: request, from: data) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
                
                completion(.success(data ?? Data()))
            }
        }.resume()
    }
}

// MARK: - Supporting Types

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

enum NetworkError: Error, LocalizedError {
    case networkError(Error)
    case invalidResponse
    case httpError(Int)
    case noData
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response received"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Response Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

struct EmptyResponse: Codable {
    // Empty response for endpoints that don't return data
}