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
    
    // MARK: - Async/Await Methods
    
    func performRequest<T: Codable>(
        url: URL,
        method: HTTPMethod = .GET,
        headers: [String: String]? = nil,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
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
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(responseType, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - Async Convenience Methods
    
    func get<T: Codable>(
        url: URL,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await performRequest(url: url, method: .GET, headers: headers, responseType: responseType)
    }
    
    func post<T: Codable>(
        url: URL,
        headers: [String: String]? = nil,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await performRequest(url: url, method: .POST, headers: headers, body: body, responseType: responseType)
    }
    
    func put<T: Codable>(
        url: URL,
        headers: [String: String]? = nil,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await performRequest(url: url, method: .PUT, headers: headers, body: body, responseType: responseType)
    }
    
    func delete<T: Codable>(
        url: URL,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await performRequest(url: url, method: .DELETE, headers: headers, responseType: responseType)
    }
    
    // MARK: - Upload Methods
    
    func uploadData(
        url: URL,
        data: Data,
        headers: [String: String]? = nil
    ) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (responseData, response) = try await urlSession.upload(for: request, from: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        return responseData
    }
    
    // MARK: - Legacy Completion Handler Methods (for backward compatibility)
    
    func performRequest<T: Codable>(
        url: URL,
        method: HTTPMethod = .GET,
        headers: [String: String]? = nil,
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        Task {
            do {
                let result = try await performRequest(url: url, method: method, headers: headers, body: body, responseType: responseType)
                await MainActor.run {
                    completion(.success(result))
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    completion(.failure(error))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(.networkError(error)))
                }
            }
        }
    }
    
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
    
    func uploadData(
        url: URL,
        data: Data,
        headers: [String: String]? = nil,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        Task {
            do {
                let result = try await uploadData(url: url, data: data, headers: headers)
                await MainActor.run {
                    completion(.success(result))
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    completion(.failure(error))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(.networkError(error)))
                }
            }
        }
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