import UIKit

extension UITableView {
    func registerCell(name : String, bundle : Bundle) {
        let nib = UINib(nibName: name, bundle: bundle)
        self.register(nib, forCellReuseIdentifier: name)
    }
}
