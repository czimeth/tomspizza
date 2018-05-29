import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher

final class CustomPizzaViewController : DetailViewController {
    override func configureTableViewBinding() {
        super.configureTableViewBinding()
        if let vm = viewModel as? CustomPizzaDetailViewModel {
            self.tableView.rx.itemSelected.map { indexPath in try! self.dataSource?.model(at: indexPath) as! PizzaDetailPresentable }.subscribe(vm.selectedAction.inputs).disposed(by: self.disposeBag)
        }
    }
}
