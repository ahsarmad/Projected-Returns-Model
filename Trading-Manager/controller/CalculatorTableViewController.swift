import UIKit

class CalculatorTableViewController: UITableViewController {

    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    @IBOutlet weak var monthlyDollarCostAveragingTextField: UITextField!
    @IBOutlet weak var initialDateOfInvestmentTextField: UITextField!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var assetNameLabel: UILabel! 
    @IBOutlet var currencyLabel: [UILabel]!
    @IBOutlet weak var investmentAmountCurrencyLabel: UILabel!

    var asset: Asset?

    private var initialDateOfInvestmentIndex: Int?

    override func viewDidLoad() {

        super.viewDidLoad()
        setUpViews()
        setUpTextFields()
    }

    private func setUpViews() {
        symbolLabel.text = asset?.searchResult.symbol
        nameLabel.text = asset?.searchResult.name
        investmentAmountCurrencyLabel.text = asset?.searchResult.currency
        currencyLabel.forEach { (label) in 
            label.text = asset?.searchResult.currency.addBrackets()
        }
    }

    private func setUpTextFields() {
        initialInvestmentAmountTextField.addDoneButton()
        monthlyDollarCostAveragingTextField.addDoneButton()
        initialDateOfInvestmentTextField.delegate = self
          
    } 

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDateSelection",
            let dateSelectionTableViewController = segue.destination as? DateSelectionTableViewController, 
            let timeSeriesMonthlyAdjusted = sender as? TimeSeriesMonthlyAdjusted {
                dateSelectionTableViewController.timeSeriesMonthlyAdjusted = timeSeriesMonthlyAdjusted
                dateSelectionTableViewController.selectedIndex = initialDateOfInvestmentIndex
                dateSelectionTableViewController.didSelectDate = { [weak self] index in 
                    self?.handleDateSelection(at: index)
                }
            }
     }

     private func handleDateSelection(at index: Int) {

        guard navigationController?.visibleViewController is DateSelectionTableViewController else { return }
        navigationController?.popViewController(animated: true)
        if let monthInfos = asset?.timeSeriesMonthlyAdjusted.getMonthInfos() {
            initialDateOfInvestmentIndex = index
            let monthInfo = monthInfos[index]
            let dateString = monthInfo.date.MMYYFormat
            initialDateOfInvestmentTextField.text = dateString
        }
     }

}


extension CalculatorTableViewController: UITableViewDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == initialDateOfInvestmentTextField {
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted )
        }
        return false
     }
}