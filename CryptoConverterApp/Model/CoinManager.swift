//
//  CoinManager.swift
//  CryptoConverterApp
//
//  Created by admin on 21/08/20.
//  Copyright © 2020 suhas. All rights reserved.
//

import Foundation
protocol CoinManagerDelegate {
    func didConvertCoinValues(coin: CoinModel)
    func didUpdateWithError(error: Error)
    func didUpdateWithParseError(coin: CoinModel)
}

struct CoinManager {
    var cryptoCoins = ["BTC", "ETN", "LTC"]
    var fiatCurrency = ["USD", "INR", "EUR", "AUD", "GBP", "CAD", "JPY", "IDR", "RUB", "KRW"]
    var coinAPIBaseUrl = CryptoConverterConstants().baseURL
    var apiKey = CryptoConverterConstants().coinAPI
    var delegate : CoinManagerDelegate?
 

    func convertCurrencies(from: String, to: String, value: Double) {
        
       let coinmarketcapURL = "\(coinAPIBaseUrl)&symbol=\(from)&convert=\(to)"
        guard let url = URL(string: coinmarketcapURL) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Yype")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request){ (data, response, error) in
            if error != nil{
                self.delegate?.didUpdateWithError(error: error!)
                return
            }
            if let safeData = data{
                if let coin = self.parseJSON(coinData: safeData, forCurrency: to, amountValue: value){
                    self.delegate?.didConvertCoinValues( coin: coin)
                }
            }
        }
        task.resume()
    }
    
    func parseJSON(coinData: Data, forCurrency: String, amountValue: Double) -> CoinModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let responseStatus = decodedData.status.error_code
            if responseStatus != 0 {
                let coin = CoinModel(convertTo: 0.0, error_message: decodedData.status.error_message)
                self.delegate!.didUpdateWithParseError(coin: coin)
                return coin
            }else {
                if let decodedDataContents = decodedData.data {
                    let toCurrencyValue = decodedDataContents.quote["\(forCurrency)"][CryptoConverterConstants().price].doubleValue
                    let amount = toCurrencyValue * amountValue
                    let coin = CoinModel(convertTo: amount, error_message: decodedData.status.error_message)
                    return coin
                }
                return nil
            }
        } catch{
            print("The error is \(error)")
        }
        return nil
    }
}
