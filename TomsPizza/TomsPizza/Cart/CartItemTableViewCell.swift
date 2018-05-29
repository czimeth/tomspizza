import UIKit
import Action

final class CartItemTableViewCell : UITableViewCell {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = ""
        self.priceLabel.text = ""
        removeButton.rx.action = nil
    }
    func setupCell(presentable : CartItemPresentable, action : CocoaAction) {
        self.nameLabel.text = presentable.name
        self.priceLabel.text = presentable.price + "$" 
        removeButton.rx.action = action
    }
}
