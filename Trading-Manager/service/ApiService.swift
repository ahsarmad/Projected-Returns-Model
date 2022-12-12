//
//  ApiService.swift
//  Trading-Manager
//
//

import Foundation
import Combine

struct APISERVICE {

    enum APISERVICEError: Error {
        case encoding
        case badRequest
    }

    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
    // generated 10 free Api Keys from alpha vantage
    // using random function to get key to minimize api call restrictions
    
    let keys = ["CEQ9UITT7TZZMLIP", "SRYE0D77ZKPUN0BK", "8A82QBTR3WL6E7F7", "U48GGV2ROC3WEG2Q", "J3OI5GIT6TBP9I95", "OJVGNRX2U67PZWO5", "N8K6JFDOU6SY6J2M", "U516F0R3XNPPD5HT", "EO1KVSSMALKZG2RJ", "GOP8SBQWZB89TGGO"]
    
    func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<SearchResults, Error> {

        let result = parseQuery(text: keywords)

        var symbol = String()

        switch result {
            case .success(let query):
                symbol = query
            case .failure(let error):
                return Fail(error: error).eraseToAnyPublisher()
        }       

        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(symbol)&apikey=\(API_KEY)"
        let urlResult = parseUrl(urlString: urlString)

        switch urlResult {
            case .success(let url):
            return URLSession.shared.dataTaskPublisher(for: url)
                .map({$0.data })
                .decode(type: SearchResults.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()

            case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }


    func fetchTimeSeriesMonthlyAdjustedPublisher(keywords: String) -> AnyPublisher<TimeSeriesMonthlyAdjusted, Error>{

        let result = parseQuery(text: keywords)

        var symbol = String()

        switch result {
            case .success(let query):
                symbol = query
            case .failure(let error):
                return Fail(error: error).eraseToAnyPublisher()
        }

        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=\(symbol)&apikey=\(API_KEY)"
        
        let urlResult = parseUrl(urlString: urlString)

        switch urlResult {
            case .success(let url):
            return URLSession.shared.dataTaskPublisher(for: url)
                .map({$0.data })
                .decode(type: TimeSeriesMonthlyAdjusted.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()

            case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }


    private func parseQuery(text: String) -> Result<String, Error> {

        if let query = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return .success(query)
        } else {
            return .failure(APISERVICEError.encoding)
        }

    }

    private func parseUrl(urlString: String) -> Result<URL, Error> {
        if let url = URL(string: urlString) {
            return .success(url)
        } else {
            return .failure(APISERVICEError.badRequest)
        }
         
    }

}


