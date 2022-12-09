//
//  ApiService.swift
//  Trading-Manager
//
//

import Foundation
import Combine

struct APISERVICE {
    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
    // generated 10 free Api Keys from alpha vantage
    // using random function to get key to minimize api call restrictions
    
    let keys = ["CEQ9UITT7TZZMLIP", "SRYE0D77ZKPUN0BK", "8A82QBTR3WL6E7F7", "U48GGV2ROC3WEG2Q", "J3OI5GIT6TBP9I95", "OJVGNRX2U67PZWO5", "N8K6JFDOU6SY6J2M", "U516F0R3XNPPD5HT", "EO1KVSSMALKZG2RJ", "GOP8SBQWZB89TGGO"]
    
    func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<SearchResults, Error> {
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keywords)&apikey=\(API_KEY)"
        
        let url = URL(string: urlString)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({$0.data })
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}


