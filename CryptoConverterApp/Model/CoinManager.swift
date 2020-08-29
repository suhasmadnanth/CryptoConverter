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
}

struct CoinManager {
    var cryptoCoins = ["BTC", "ETN", "LTC"]
    var fiatCurrency = ["USD", "INR", "EUR", "AUD", "GBP", "CAD", "JPY", "IDR", "RUB", "KRW"]
    var coinAPIBaseUrl = "https://pro-api.coinmarketcap.com/v1/tools/price-conversion?amount=1"
    var apiKey = ""
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
                print("error is \(error)")
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
            let toCurrencyValue = decodedData.data.quote["\(forCurrency)"]["price"].doubleValue
            let amount = toCurrencyValue * amountValue
            let coin = CoinModel(convertTo: amount)
            return coin
        }catch{
            print("The error is \(error)")
        }
        return nil
    }
}
