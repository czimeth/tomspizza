import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class CartViewController : UIViewController {
    static let bundle = Bundle.init(for: CartViewController.self)
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var viewModel : CartViewModelProtocol?
    let disposeBag = DisposeBag()
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navController = self.navigationController, !navController.viewControllers.contains(self) {
            self.viewModel?.pop()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = nil
        self.tableView.registerCell(name: CartItemTableViewCell.reuseID, bundle: CartViewController.bundle)
        self.tableView.registerCell(name: TotalTableViewCell.reuseID, bundle: CartViewController.bundle)
        self.navigationItem.backBarButtonItem?.title = ""
        var button = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_drinks"), style: .plain, target: nil, action: nil)
        button.setBackgroundImage(#imageLiteral(resourceName: "ic_drinks").withRenderingMode(.alwaysTemplate), for: .normal, barMetrics: UIBarMetrics.default)
        button.tintColor = UIColor(red: 71/255, green: 104/255, blue: 173/255, alpha: 1)
        button.rx.action = viewModel?.routeToDrinks()
        checkoutButton.rx.action = viewModel?.postCart()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.title = "CART"
        let isThereAnyItem = viewModel?.cartPresentables.asObservable().flatMap({ (presentables) -> Observable<Bool> in
            return Observable.of(presentables.first?.items.count != 0)
        }).share().asDriver(onErrorJustReturn: false).asObservable()
        isThereAnyItem?.bind(to: checkoutButton.rx.isEnabled).disposed(by: self.disposeBag)
        self.navigationItem.rightBarButtonItem = button
        self.tableView.tableFooterView = UIView()
        configureTableViewBinding()
    }
    private func configureTableViewBinding() {
        if let viewModel = self.viewModel {
            let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCartItemPresentable>(configureCell: { [weak self]
                (ds: TableViewSectionedDataSource<SectionOfCartItemPresentable>, tableView: UITableView, ip: IndexPath, item: SectionOfCartItemPresentable.Item) -> UITableViewCell  in
                if let presentable = item as? CartItemPresentable,
                    let cell = self?.tableView.dequeueReusableCell(ofType: CartItemTableViewCell.self, at: ip), let action = self?.viewModel?.removeFromCart(item: presentable) {
                    cell.setupCell(presentable: presentable, action: action)
                    return cell
                } else if let total = item as? TotalPresentable, let cell = self?.tableView.dequeueReusableCell(ofType: TotalTableViewCell.self, at: ip) {
                    cell.totalPrice.text = total.price + "$"
                    return cell
                }
                return UITableViewCell()
            })
            viewModel.cartPresentables.asDriver().asObservable().bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by:disposeBag)
            tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
        }
    }
}
extension CartViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
