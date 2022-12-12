import UIKit

class DateSelectionTableViewController: UITableViewController {

    var timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjusted?
    var monthInfos: [MonthInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMonthInfos()
    }

    private func setUpMonthInfos() {
        if let monthInfos = timeSeriesMonthlyAdjusted?.monthInfos() {
            self.monthInfos = monthInfos
        }
    }

}

extension DateSelectionTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int { 
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthInfos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { 
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as!
            DateSelectionTableViewCell
        let monthInfo = monthInfos[indexPath.item]
        cell.configure(with: monthInfo)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
     }
}



class DateSelectionTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthsAgoLabel: UILabel!

    func configure (with monthInfo: MonthInfo) {
        backgroundColor = .red
    }

}

