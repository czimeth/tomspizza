import Foundation
import Kingfisher
import Action

final class PizzaListTableViewCell : UITableViewCell {
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageVIew: UIImageView!
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            let image = #imageLiteral(resourceName: "ic_cart_button").withRenderingMode(.alwaysTemplate)
            addButton.setImage(image, for: .normal)
            addButton.tintColor = UIColor(red: 71/255, green: 104/255, blue: 173/255, alpha: 1)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.ingredientsLabel.text = ""
        self.priceLabel.text = ""
        self.nameLabel.text = ""
        self.imageVIew.image = nil
    }
    
    func setupCell(pizzaPresentable : PizzaItemPresentable, action: CocoaAction){
        addButton.rx.action = action
        self.ingredientsLabel.text = pizzaPresentable.ingredients
        self.priceLabel.text = pizzaPresentable.price
        self.nameLabel.text = pizzaPresentable.name
        if let url = URL(string: pizzaPresentable.imagURL) {
            self.imageVIew.kf.setImage(with: url)
        }
        
    }
}
