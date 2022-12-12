import UIKit

class CalculatorTableViewController: UITableViewController {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var currencyLabel: [UILabel]!

    var asset: Asset?

    override func viewDidLoad() {

        super.viewDidLoad()
        setUpViews()
    }

    private func setUpViews() {
        symbolLabel.text = asset?.searchResult.symbol
        nameLabel.text = asset?.searchResult.name
        currencyLabel.forEach { (label) in 
        label.text = asset?.searchResult.currency.addBrackets()
        }
    }
}