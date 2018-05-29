import UIKit

final class PizzaDetailTableViewCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = ""
        self.priceLabel.text = ""
        self.iconLabel.isHidden = false
    }
    
    func setupCell(presentable : PizzaDetailPresentable) {
        self.nameLabel.text = presentable.name
        self.priceLabel.text = presentable.price
        self.iconLabel.isHidden = !presentable.checked
    }
}
