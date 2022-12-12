//
//  ViewController.swift
//  Trading-Manager
//
//

import UIKit
import Combine
import MBProgressHUD

class SearchTableViewController: UITableViewController, UIAnimatable {
    
    private enum Mode {
        case onBoarding
        case search
    }
    
    private lazy var searchController : UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or ticker symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        
        return sc
    } ()
    
    
    private let apiService = APISERVICE()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: SearchResults?

    @Published private var mode: Mode = .onBoarding
    @Published private var searchQuery = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpTableView()
        observeForm()
        
    }

    
    private func setUpNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.title = "Search"
    }
    
    
    private func setUpTableView(){
        tableView.tableFooterView = UIView()
    }
    
    private func observeForm() {
        $searchQuery.debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink{ [unowned self](searchQuery) in
                guard !searchQuery.isEmpty else { return }
                showLoadingAnimation()
                self.apiService.fetchSymbolsPublisher(keywords: searchQuery).sink { (completion) in
                    hideLoadingAnimation()
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished: break
                    }
                } receiveValue: { (searchResults) in
                    self.searchResults = searchResults
                    self.tableView.reloadData()
                }.store(in: &self.subscribers)
            }.store(in: &subscribers)
            
        $mode.sink{[unowned self](mode) in
            switch mode {
            case .onBoarding:
                self.tableView.backgroundView = SearchPlaceHolderView()
            case.search:
                self.tableView.backgroundView = nil
            }
        }.store(in: &subscribers)
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> 
    UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as!
        SearchTableViewCell
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items[indexPath.row]
            cell.configure(with: searchResult )

        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items[indexPath.item]
            let symbol = searchResult.symbol
            handleSelection(for: symbol, searchResult: searchResult)
        }
    }

    private func handleSelection(for symbol: String, searchResult: SearchResult) {

        apiService.fetchTimeSeriesMonthlyAdjustedPublisher(keywords: symbol). sink {
            (completionResult) in 
            switch completionResult {
                case .failure(let error):
                    print(error)
                case .finished: break
            }
        } receiveValue: {[weak self](timeSeriesMonthlyAdjusted) in 

            let asset = Asset(searchResult: SearchResult, timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
            self?.performSegue(withIdentifier: "showCalculator", sender: asset)

        print("success: \(timeSeriesMonthlyAdjusted.getMonthInfos())")
        }.store(in: &subscribers)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCalculator", let destination = segue.destination as? CalculatorTableViewController, 
        let asset = sender as? Asset {
        destination.asset = asset
        }
    }

}


extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty else { return }
        self.searchQuery = searchQuery
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
    mode = .search
    }
}

