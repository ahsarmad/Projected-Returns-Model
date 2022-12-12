import UIKit
import Combine

class CalculatorTableViewController: UITableViewController {

    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    @IBOutlet weak var monthlyDollarCostAveragingTextField: UITextField!
    @IBOutlet weak var initialDateOfInvestmentTextField: UITextField!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var assetNameLabel: UILabel! 
    @IBOutlet var currencyLabel: [UILabel]!
    @IBOutlet weak var investmentAmountCurrencyLabel: UILabel!
    @IBOutlet weak var dateSlider: UISlider!

    var asset: Asset?

   @Published private var initialDateOfInvestmentIndex: Int?

   private var subscribers = Set<AnyCancellable>()

    override func viewDidLoad() {

        super.viewDidLoad()
        setUpViews()
        setUpTextFields()
        setUpDateSlider()
        observeForm()
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

    private func setUpDateSlider () {
        if let count = asset?.timeSeriesMonthlyAdjusted.getMonthInfos().count {
            let dateSliderCount = count - 1
            dateSlider.maximumValue = dateSliderCount.floatValue
        }
    }

    private func observeForm() {
        $initialDateOfInvestmentIndex.sink {[weak self] (index) in 
            guard let index = index else { return }
            self?.dateSlider.value = index.floatValue
            if let dateString = self?.asset?.timeSeriesMonthlyAdjusted.getMonthInfos()[index].date.MMYYFormat {
                self?.initialDateOfInvestmentTextField.text = dateString
            }
        }.store( in: &subscribers )
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

     @IBAction func dateSliderDidChange(_sender: UISlider) {
        initialDateOfInvestmentIndex = Int(sender.value)
     }

}


extension CalculatorTableViewController: UITableViewDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == initialDateOfInvestmentTextField {
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted )
            return false
        }
        return true
     }
}