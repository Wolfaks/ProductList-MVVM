
import UIKit

protocol DetailViewModeltDelegate: class {
    func changeCartCount(index: Int, value: Int)
}

protocol DetailViewModelProtocol {
    var title: String { get }
    var producer: String { get }
    var shortDescription: String { get }
    var image: UIImage { get }
    var price: String { get }
    var selectedAmount: Int { get set }
    var bindToController: () -> () { get set }
    var delegate: DetailViewModeltDelegate? { get set }
    func numberOfRows() -> Int
    func changeCartCount(index: Int, count: Int)
    func cellViewModel(forIndexPath indexPath: IndexPath) -> DetailCellViewModalProtocol?
}

class DetailViewModel: DetailViewModelProtocol {

    let id: Int

    var title: String = ""
    var producer: String = ""
    var shortDescription: String = ""
    var imageUrl: String = ""
    var image: UIImage
    var price: String = ""
    var categoryList: [Category] = []
    var selectedAmount: Int = 0

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

                self?.title = product.title
                self?.producer = product.producer
                self?.shortDescription = product.shortDescription
                self?.imageUrl = product.imageUrl

                // Убираем лишние нули после запятой, если они есть и выводим цену
                self?.price = String(format: "%g", product.price) + " ₽"

                // categories
                if let categories = product.categories {
                    self?.categoryList = categories
                }

                // Загрузка изображения, если ссылка пуста, то выводится изображение по умолчанию
                if !(self?.imageUrl.isEmpty ?? false) {

                    // Загрузка изображения
                    if let imageURL = URL(string: (self?.imageUrl)!) {

                        ImageNetworking.shared.getImage(link: imageURL) { (img) in
                            DispatchQueue.global(qos: .userInitiated).sync {
                                self?.image = img
                            }
                        }

                    }

                }

                // Обновляем данные в контроллере
                self?.bindToController()

            }

        }

    }

    func numberOfRows() -> Int {
        categoryList.count
    }

    func cellViewModel(forIndexPath indexPath: IndexPath) -> DetailCellViewModalProtocol? {
        let category = categoryList[indexPath.row]
        return DetailCellViewModel(category: category)
    }

    func changeCartCount(index: Int, count: Int) {

        // Обновляем значение
        selectedAmount = count
        
        delegate?.changeCartCount(index: index, value: count)

    }

}
