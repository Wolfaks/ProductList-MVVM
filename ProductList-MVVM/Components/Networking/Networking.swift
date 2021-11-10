
import UIKit

class Networking {

    // Создаем синглтон для обращения к методам класса
    private init() {}
    
    static let shared = Networking()

    public func getData(link: String, params: [String: String], completion: @escaping (String) -> ()) {

        let session = URLSession.shared

        // Подготовка URL
        guard let urlWithParams = NSURLComponents(string: link) else {
            return
        }

        // Параметры запроса
        var parameters = [URLQueryItem]()
        for (key, value) in params {
            parameters.append(URLQueryItem(name: key, value: value))
        }

        if !parameters.isEmpty {
            urlWithParams.queryItems = parameters
        }
        // END Параметры запроса

        guard let url = urlWithParams.url else {
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        // Выполняем запрос по URL
        session.dataTask(with: urlRequest) { data, response, error in

            guard let data = data else { return }

            do {

                if let result = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async(execute: {
                        completion(result)
                    })
                }

            } catch {
                print(error)
            }

        }.resume()

    }

}
