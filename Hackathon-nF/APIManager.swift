import Foundation
import AVFoundation

// Structs for decoding responses
struct OpenAIResponse: Codable {
    var choices: [Choice]
}

struct Choice: Codable {
    var finishReason: String
    var index: Int
    var message: Message
}

struct Message: Codable {
    var content: String
}

struct AudioSummary {
    var title: String
    var summary: String
    var audioURL: URL
}

// API Manager class for handling API requests
class APIManager {
    static let shared = APIManager()
    private let apiKey = ""
    private let bingKey = ""
    
    func fetchNews(query: String, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "https://api.bing.microsoft.com/v7.0/news/search"
        var urlComponents = URLComponents(string: endpoint)!
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "mkt", value: "en-US"),
            URLQueryItem(name: "freshness", value: "Day")
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.setValue(bingKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let json = try? JSONDecoder().decode(OpenAIResponse.self, from: data) else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
                return
            }

            let newsContent = json.choices.map { $0.message.content }.joined(separator: "\n")
            completion(.success(newsContent))
        }.resume()
    }
    
    func synthesizeSpeech(from text: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let urlString = "https://api.openai.com/v1/audio/speech"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(["model": "text:audio", "input": text])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "NetworkError", code: -2, userInfo: nil)))
                return
            }

            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("summary.mp3")
            do {
                try data.write(to: fileURL)
                completion(.success(fileURL))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
