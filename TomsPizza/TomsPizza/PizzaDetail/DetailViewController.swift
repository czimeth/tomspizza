import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class DetailViewController : UIViewController {
    static let bundle = Bundle.init(for: DetailViewController.self)
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pizzaImage: UIImageView!
    @IBOutlet weak var addToCartButton: UIButton!
    var viewModel : DetailViewModelProtocol?
    var dataSource : RxTableViewSectionedReloadDataSource<SectionOfPizzaDetailPresentable>?
    let disposeBag = DisposeBag()
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navController = self.navigationController, !navController.viewControllers.contains(self) {
            self.viewModel?.pop()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerCell(name: PizzaDetailTableViewCell.reuseID, bundle: DetailViewController.bundle)
        configureTableViewBinding()
        self.viewModel?.pizza.map({ (pizza) -> URL? in return URL(string: (pizza.imageURL ?? ""))}).asDriver(onErrorJustReturn: nil).asObservable().subscribe(onNext: { (imageURL) in
            self.pizzaImage.kf.setImage(with: imageURL)
        }).disposed(by: self.disposeBag)
        self.viewModel?.pizza.flatMap({ (pizza) -> Observable<String> in
            return Observable.of(pizza.name)
        }).asDriver(onErrorJustReturn: "").asObservable().bind(to: self.navigationItem.rx.title).disposed(by: self.disposeBag)
        
    }
    func configureTableViewBinding() {
        if let viewModel = self.viewModel {
            self.dataSource = RxTableViewSectionedReloadDataSource<SectionOfPizzaDetailPresentable>(configureCell: {
                (ds: TableViewSectionedDataSource<SectionOfPizzaDetailPresentable>, tableView: UITableView, ip: IndexPath, item: SectionOfPizzaPresentable.Item) -> UITableViewCell in
                if let presentable = item as? PizzaDetailPresentable {
                    let cell = self.tableView.dequeueReusableCell(ofType: PizzaDetailTableViewCell.self, at: ip)
                    cell.setupCell(presentable: presentable)
                    return cell
                }
                return UITableViewCell()
            })
            if let ds = self.dataSource {
                viewModel.pizzaDetailPresentables.asDriver(onErrorJustReturn: []).asObservable().bind(to: tableView.rx.items(dataSource: ds)).disposed(by: self.disposeBag)
            }
            tableView.rx.setDelegate(self).disposed(by: disposeBag)
            addToCartButton.rx.action = viewModel.addToCartAction()
        }
    }
}
extension DetailViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
