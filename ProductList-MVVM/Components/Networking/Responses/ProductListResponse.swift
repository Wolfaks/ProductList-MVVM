
import Foundation

struct ProductListResponse: Decodable, ApiResponse {
    var products = [Product]()
    
    enum CodingKeys: String, CodingKey {
        case products = "data"
    }
    
    mutating func decodeJson(json: String) {
        
        // Обрабатываем полученные данные
        guard !json.isEmpty else { return }
        
        let jsonData = Data(json.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let responseDecode = try decoder.decode(ProductListResponse.self, from: jsonData)
            self.products = responseDecode.products
        } catch {
            //print(error)
        }
        
    }
}
