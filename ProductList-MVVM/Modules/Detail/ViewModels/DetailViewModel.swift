
import UIKit

protocol DetailViewModeltDelegate: class {
    func changeCartCount(index: Int, value: Int)
}

protocol DetailViewModelProtocol {
    var image: UIImage { get }
    var selectedAmount: Int { get set }
    var product: Product? { get }
    var bindToController: () -> () { get set }
    var delegate: DetailViewModeltDelegate? { get set }
    func numberOfRows() -> Int
    func changeCartCount(index: Int, count: Int)
    func cellViewModel(forIndexPath indexPath: IndexPath) -> DetailCellViewModalProtocol?
}

class DetailViewModel: DetailViewModelProtocol {

    let id: Int
    var image: UIImage
    var selectedAmount: Int = 0
    var product: Product?

    var bindToController : () -> () = {}
    weak var delegate: DetailViewModeltDelegate?

    init(productID: Int, amount: Int) {
        id = productID
        selectedAmount = amount
        image = UIImage(named: "nophoto")!
        loadProduct()
    }

    private func loadProduct() {

        // Отправляем запрос загрузки товара
        ProductDetailService.getOneProduct(id: id) { [weak self] (response) in

            // Проверяем что данные были успешно обработаны
            if let product = response.product {

                // Загрузка изображения, если ссылка пуста, то выводится изображение по умолчанию
                if !product.imageUrl.isEmpty {

                    // Загрузка изображения
                    if let imageURL = URL(string: product.imageUrl) {

                        ImageNetworking.shared.getImage(link: imageURL) { (img) in
                            DispatchQueue.global(qos: .userInitiated).sync {
                                self?.image = img
                            }
                        }

                    }

                }
                
                self?.product = product

                // Обновляем данные в контроллере
                self?.bindToController()

            }

        }

    }

    func numberOfRows() -> Int {
        product?.categories?.count ?? 0
    }

    func cellViewModel(forIndexPath indexPath: IndexPath) -> DetailCellViewModalProtocol? {
        guard let categories = product?.categories else { return nil }
        let category = categories[indexPath.row]
        return DetailCellViewModel(category: category)
    }

    func changeCartCount(index: Int, count: Int) {

        // Обновляем значение
        selectedAmount = count
        delegate?.changeCartCount(index: index, value: count)

    }

}
