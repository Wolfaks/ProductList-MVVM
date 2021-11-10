
import Foundation

struct ProductResponse: Decodable, ApiResponse {
    var product: Product?
    
    enum CodingKeys: String, CodingKey {
        case product = "data"
    }
    
    mutating func decodeJson(json: String) {
        
        // Обрабатываем полученные данные
        guard !json.isEmpty else { return }
        
        let jsonData = Data(json.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let responseDecode = try decoder.decode(ProductResponse.self, from: jsonData)
            self.product = responseDecode.product
        } catch {
            //print(error)
        }
        
    }
}
