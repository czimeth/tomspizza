import UIKit
import RxCocoa
import RxSwift
import RxDataSources

final class DrinksViewController : UIViewController {
    static let bundle = Bundle.init(for: DetailViewController.self)
    @IBOutlet weak var tableView: UITableView!
    var viewModel : DrinksViewModelProtocol?
    var dataSource : RxTableViewSectionedReloadDataSource<SectionOfDrinkPresentable>?
    let disposeBag = DisposeBag()
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navController = self.navigationController, !navController.viewControllers.contains(self) {
            self.viewModel?.pop()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerCell(name: DrinkTableViewCell.reuseID, bundle: DrinksViewController.bundle)
        configureTableViewBinding()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.backBarButtonItem?.title = ""
    }
    func configureTableViewBinding() {
        if let viewModel = self.viewModel {
            self.dataSource = RxTableViewSectionedReloadDataSource<SectionOfDrinkPresentable>(configureCell: {
                (ds: TableViewSectionedDataSource<SectionOfDrinkPresentable>, tableView: UITableView, ip: IndexPath, item: SectionOfDrinkPresentable.Item) -> UITableViewCell in
                    let cell = self.tableView.dequeueReusableCell(ofType: DrinkTableViewCell.self, at: ip)
                    if let drink = item as? Drink {
                        cell.addButton.rx.action = viewModel.addItemToCart(id: drink.id)
                        cell.nameLabel.text = drink.name
                        cell.priceLabel.text = String(describing: drink.price) + "$"
                    }
                    return cell
            })
            if let ds = self.dataSource {
                viewModel.drinkPresentables.asDriver(onErrorJustReturn: []).asObservable().bind(to: self.tableView.rx.items(dataSource: ds)).disposed(by: self.disposeBag)
            }
            tableView.rx.setDelegate(self).disposed(by: disposeBag)
        }
    }
}
extension DrinksViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
