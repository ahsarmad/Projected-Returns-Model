//
//  ViewController.swift
//  Trading-Manager
//
//

import UIKit
import Combine

class SearchTableViewController: UITableViewController {
    
    private lazy var searchController : UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Please enter a company's name or ticker symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        
        return sc
    } ()
    
    
    private let apiService = APISERVICE()
    private var subscribers = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        performSearch()
    }

    
    private func setUpNavigationBar() {
        navigationItem.searchController = searchController
    }
    
    private func performSearch() {
        apiService.fetchSymbolsPublisher(keywords: "AMZ").sink { (completion) in
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
            case .finished: break
            }
        } receiveValue: { (searchResults) in
            print(searchResults)
        }.store(in: &subscribers)

        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        return cell
    }

}


extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {

    }
}

