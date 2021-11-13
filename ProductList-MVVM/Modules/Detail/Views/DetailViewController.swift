
import UIKit

protocol DetailViewtDelegate: class {
    func changeCartCount(index: Int, value: Int)
}

class DetailViewController: UIViewController {
    
    var productIndex: Int?
    var productID: Int?
    var productTitle: String?
    var productSelectedAmount = 0
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var producerLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cartBtnDetailView: CartBtnDetail!
    @IBOutlet weak var cartCountView: CartCount!

    // viewModel
    var viewModel: DetailViewModelProtocol!
    
    weak var delegate: DetailViewtDelegate?

    static func storyboardInstance() -> DetailViewController? {
        // Для перехода на эту страницу
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "Detail") as? DetailViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingUI()
    }
    
    private func settingUI() {

        // Задаем заголовок страницы
        if let productTitle = productTitle {
            title = productTitle
        }
        
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Запрос данных
        // viewModel
        if let id = productID {
            viewModel = DetailViewModel(productID: id, amount: productSelectedAmount)
            viewModel.delegate = self
            viewModel.bindToController = { [weak self] in
                
                guard let product = self?.viewModel.product else { return }

                // Скрываем анимацию загрузки
                self?.loadIndicator.stopAnimating()

                // Задаем обновленный заголовок страницы
                self?.title = product.title

                // Выводим информацию
                self?.titleLabel.text = product.title
                self?.producerLabel.text = product.producer
                self?.image.image = self?.viewModel.image
                
                // Убираем лишние нули после запятой, если они есть и выводим цену
                self?.priceLabel.text = String(format: "%g", product.price) + " ₽"

                // Описание
                self?.changeDescription(text: product.shortDescription)

                // Вывод корзины и кол-ва добавленых в корзину
                self?.setCartButtons()

                // Оббновляем таблицу
                self?.tableView.reloadData()

                // Отображаем данные
                self?.infoStackView.isHidden = false

            }
        }
        
    }
    
    private func setCartButtons() {

        guard let viewModel = viewModel else { return }

        // Вывод корзины и кол-ва добавленых в корзину
        if viewModel.selectedAmount > 0 {
            
            // Выводим переключатель кол-ва продукта в корзине
            cartBtnDetailView.isHidden = true
            cartCountView.isHidden = false
            
            // Задаем текущее значение счетчика
            cartCountView.count = viewModel.selectedAmount
            
            // Подписываемся на делегат
            cartCountView.delegate = self
            
        } else {
            // Выводим кнопку добавления в карзину
            cartBtnDetailView.isHidden = false
            cartBtnDetailView.delegate = self
            cartCountView.isHidden = true
        }
        
    }
    
    private func changeDescription(text: String) {
        
        // Задаем описание
        if text.isEmpty {
            descriptionLabel.isHidden = true
            descriptionLabel.text = ""
        } else {
            descriptionLabel.isHidden = false
            descriptionLabel.text = text
        }
        
    }
    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.numberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryListTableCell, let viewModel = viewModel else { return UITableViewCell() }

        let cellViewModel = viewModel.cellViewModel(forIndexPath: indexPath)
        cell.viewModel = cellViewModel

        return cell

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
    }

}

extension DetailViewController: CartCountDelegate {
    
    func changeCount(value: Int) {
        
        // Изменяем значение количества в структуре
        guard let productIndex = productIndex, viewModel != nil else { return }

        // Обновляем кнопку в отображении
        viewModel.changeCartCount(index: productIndex, count: value)
        setCartButtons()
        
    }
    
}

extension DetailViewController: CartBtnDetailDelegate {
    
    func addCart() {

        // Добавляем товар в карзину
        guard let productIndex = productIndex, viewModel != nil else { return }

        let addCartCount = 1

        // Обновляем кнопку в отображении
        viewModel.changeCartCount(index: productIndex, count: addCartCount)
        setCartButtons()
        
    }
    
}

extension DetailViewController: DetailViewModeltDelegate {
    
    func changeCartCount(index: Int, value: Int) {
        
        // Записываем новое значение
        delegate?.changeCartCount(index: index, value: value)
        
    }
    
}
