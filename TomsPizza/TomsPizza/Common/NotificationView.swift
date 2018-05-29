import UIKit

final class NotificationView : UIView {
        var contentView : UIView?
        override init(frame: CGRect) {
            super.init(frame: frame)
            xibSetup()
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            xibSetup()
        }
        func xibSetup() {
            contentView = loadViewFromNib()
            contentView!.frame = bounds
            contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
            addSubview(contentView!)
        }
        func loadViewFromNib() -> UIView! {
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
            let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
            return view
        }
}
