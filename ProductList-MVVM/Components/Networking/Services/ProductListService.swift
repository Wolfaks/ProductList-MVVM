
import Foundation

class ProductListService {
    
    private init() {}
    
    static func getProducts(page: Int, searchText: String, complition: @escaping(ProductListResponse) -> ()) {
        
        // Подготовка параметров для запроса, задаем макс количество элементов = 21
        var params = ["maxItems": "\(Constants.Settings.maxProductsOnPage)"]

        // Страница
        var startFrom = 0
        if page > 0 {
            startFrom = ((page - 1) * (Constants.Settings.maxProductsOnPage - 1));
        }
        params["startFrom"] = "\(startFrom)"

        // Поиск
        if !searchText.isEmpty {
            params["filter[title]"] = searchText
        }
        
        // Получаем список
        Networking.shared.getData(link: Constants.Urls.productsList, params: params) { result in
            do {
                var productListResponse = ProductListResponse()
                productListResponse.decodeJson(json: result)
                complition(productListResponse)
            } catch {
                print(error)
            }
        }
        
    }
}
