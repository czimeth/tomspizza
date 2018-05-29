import UIKit
import RxSwift

final class ThankYouViewController : UIViewController {
    var coordinator : SceneCoordinatorType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.coordinator?.pop()
        }
    }
}
