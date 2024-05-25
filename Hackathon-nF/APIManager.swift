import Foundation
import AVFoundation

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
    var role: String
}


class APIManager {
    static let shared = APIManager()
    private let apiKey = ""
    private let bingKey = ""

    
    func fetchNews(query: String, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "https://api.bing.microsoft.com/v7.0/news/search"
        let queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "mkt", value: "en-US"),
            URLQueryItem(name: "freshness", value: "Day")
        ]
        var urlComponents = URLComponents(string: endpoint)!
        urlComponents.queryItems = queryItems

        var request = URLRequest(url: urlComponents.url!)
        request.setValue(bingKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            if let error = error {
                print("Error fetching news: \(error.localizedDescription)")
                return
            }
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let value = json["value"] as? [[String: Any]] else {
                print("No data received or data could not be converted to JSON")
                return
            }

            // Collect news titles and descriptions for summarization
            var newsContent = ""
            for article in value {
                if let title = article["name"] as? String,
                   let url = article["url"] as? String,
                   let description = article["description"] as? String {
                    newsContent += "\(title)\n\(description)\n\n"
                    print("Title: \(title)")
                    print("URL: \(url)")
                    print("Description: \(description)\n")
                }
            }
            
            // Call summarizeNews here with collected news content
            self.summarizeNews(text: newsContent) { result in
                switch result {
                case .success(let summary):
                    print("Summary: \(summary)")
                case .failure(let error):
                    print("Error summarizing news: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }

    
    func synthesizeSpeech(from text: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let urlString = "https://api.openai.com/v1/audio/speech"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": "text:audio",
            "input": text
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "NetworkError", code: -2, userInfo: nil)))
                return
            }

            // Save the audio data to a file
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("summary.mp3")
            do {
                try data.write(to: fileURL)
                completion(.success(fileURL))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    func summarizeNews(text: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://api.openai.com/v1/chat/completions"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": "You are a news presenter. Provide a comprehensive summary of this news. Include all key details: " + text]
            ],
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "NetworkError", code: -2, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(OpenAIResponse.self, from: data)
                if let firstMessageContent = response.choices.first?.message.content {
                    completion(.success(firstMessageContent))
                } else {
                    completion(.failure(NSError(domain: "ParsingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Message content is missing"])))
                }
            } catch {
                print("Failed to decode JSON: \(error)")
                completion(.failure(error))
            }
        }.resume()

    }
}
