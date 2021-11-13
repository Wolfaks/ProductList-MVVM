
import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var searchForm: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!

    // viewModel
    var viewModel: ListViewModelProtocol!

    // Поиск
    var searchText = ""
    private let searchOperationQueue = OperationQueue()

    // Страницы
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingUI()
    }
    
    private func settingUI() {

        // searchForm
        searchForm.delegate = self
        searchForm.addTarget(self, action: #selector(changeSearchText), for: .editingChanged) // добавляем отслеживание изменения текста
        
        // TableView
        tableView.delegate = self
        tableView.dataSource = self

        // viewModel
        viewModel = ListViewModel(page: page, searchText: searchText)
        viewModel.bindToController = { [weak self] in

            // Скрываем анимацию загрузки
            if self?.page == 1 {
                self?.loadIndicator.stopAnimating()
            }

            // Обновляем таблицу
            self?.tableView.reloadData()

        }
        
    }
    
    @IBAction func removeSearch(_ sender: Any) {
        
        // Очищаем форму поиска
        searchForm.text = ""
        
        // Скрываем клавиатуру
        hideKeyboard()
        
        // Вызываем метод поиска
        changeSearchText(textField: searchForm)
        
    }
    
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func changeSearchText(textField: UITextField) {

        // Проверяем измененный в форме текст
        guard let newSearchText = textField.text else { return }
        
        // Выполняем поиск когда форма была изменена
        if newSearchText.hash == searchText.hash {
            return
        }

        // Получаем искомую строку
        searchText = newSearchText

        // Очищаем старые данные и обновляем таблицу
        removeOldProducts()

        // Поиск с задержкой (по ТЗ)
        let operationSearch = BlockOperation()
        operationSearch.addExecutionBlock { [weak operationSearch] in

            // Задержка (по ТЗ)
            sleep(2)

            if !(operationSearch?.isCancelled ?? false) {

                // Выполняем поиск
                // Задаем первую страницу
                self.page = 1

                // Запрос данных
                self.viewModel.loadProducts(page: self.page, searchText: self.searchText)

            }

        }
        searchOperationQueue.cancelAllOperations()
        searchOperationQueue.addOperation(operationSearch)
        
    }
    
    private func removeOldProducts() {

        guard let viewModel = viewModel else { return }
        
        // Очищаем старые данные и обновляем таблицу
        viewModel.removeAllProducts()
        tableView.reloadData()
        
        // Отображаем анимацию загрузки
        loadIndicator.startAnimating()
        
    }
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {

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

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductListTableCell, let viewModel = viewModel else { return UITableViewCell() }

        let cellViewModel = viewModel.cellViewModel(forIndexPath: indexPath)
        cell.productIndex = indexPath.row
        cell.viewModel = cellViewModel
        cell.delegate = self

        return cell

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
        
        // Проверяем что оторазили последний элемент и если есть, отображаем следующую страницу
        if viewModel != nil, !viewModel.productList.isEmpty && indexPath.row == (viewModel.productList.count - 1) && viewModel.haveNextPage {

            // Задаем новую страницу
            viewModel.haveNextPage = false
            page += 1

            // Запрос данных
            viewModel.loadProducts(page: page, searchText: searchText)

        }
    }

}

extension ListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == searchForm {
            // Скрываем клавиатуру при нажатии на клавишу Done / Готово
            hideKeyboard()
        }
        
        return true
        
    }
    
}

extension ListViewController: ProductListCellDelegate, DetailViewtDelegate {
    
    func changeCartCount(index: Int, value: Int) {
        
        // Изменяем кол-во товара в корзине
        if !viewModel.productList.indices.contains(index) {
            return
        }
        
        // Записываем новое значение
        viewModel.updateCartCount(index: index, value: value)

        // Обновляем tableView
        tableView.reloadData()
        
    }
    
    func redirectToDetail(index: Int) {
        
        // Выполняем переход в детальную информацию
        if !viewModel.productList.indices.contains(index) {
            return
        }
        
        // Выполняем переход в детальную информацию
        if let detailViewController = DetailViewController.storyboardInstance() {
            detailViewController.productIndex = index
            detailViewController.productID = viewModel.productList[index].id
            detailViewController.productTitle = viewModel.productList[index].title
            detailViewController.productSelectedAmount = viewModel.productList[index].selectedAmount
            detailViewController.delegate = self
            navigationController?.pushViewController(detailViewController, animated: true)
        }
        
    }
    
}
