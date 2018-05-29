import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class PizzaListViewController : UITableViewController {
    static let bundle = Bundle.init(for: PizzaListViewController.self)
    var viewModel : PizzaListViewModelProtocol?
    let disposeBag = DisposeBag()
    @IBOutlet weak var customPizza: UIBarButtonItem!
    @IBOutlet weak var cart: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil
        self.tableView.registerCell(name: PizzaListTableViewCell.reuseID, bundle: PizzaListViewController.bundle)
        self.customPizza.rx.action = self.viewModel?.showCustomPizza()
        self.cart.rx.action = self.viewModel?.showCart()
        self.navigationController?.navigationBar.tintColor = UIColor(red: 71/255, green: 104/255, blue: 173/255, alpha: 1)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        configureTableViewBinding()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 178
    }
    
    private func configureTableViewBinding() {
        if let viewModel = self.viewModel {
            let dataSource = RxTableViewSectionedReloadDataSource<SectionOfPizzaPresentable>(configureCell: { [weak self]
                (ds: TableViewSectionedDataSource<SectionOfPizzaPresentable>, tableView: UITableView, ip: IndexPath, item: SectionOfPizzaPresentable.Item) -> UITableViewCell  in
                if let presentable = item as? PizzaItemPresentable,
                    let cell = self?.tableView.dequeueReusableCell(ofType: PizzaListTableViewCell.self, at: ip), let action = self?.viewModel?.addToCart(item: presentable) {
                    cell.setupCell(pizzaPresentable: presentable, action: action)
                    return cell
                }
                return UITableViewCell()
            })
            viewModel.pizzaPresentables.asDriver(onErrorJustReturn: []).asObservable().bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
            self.tableView.rx.itemSelected
                .map { indexPath in
                    try! dataSource.model(at: indexPath) as! PizzaItemPresentable
                }
                .subscribe(viewModel.selectedAction.inputs)
                .disposed(by: self.disposeBag)
        }
    }
}
