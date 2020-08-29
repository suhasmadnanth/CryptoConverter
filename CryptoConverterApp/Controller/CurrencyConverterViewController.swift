//
//  CurrencyConverterViewController.swift
//  CryptoConverterApp
//
//  Created by admin on 20/08/20.
//  Copyright © 2020 suhas. All rights reserved.
//

import UIKit

class CurrencyConverterViewController: UIViewController, CoinManagerDelegate {
    
    @IBOutlet weak var fromCurrencyConverterButton: UIButton!
    @IBOutlet weak var toCurrencyConverterButton: UIButton!
    @IBOutlet weak var fromCurrencyConverterTextField: UITextField!
    @IBOutlet weak var toCurrencyConverterTextField: UITextField!
    @IBOutlet weak var cryptoCoinsPicker: UIPickerView!
    var coinManager = CoinManager()
    var fromCurrencyFlag = 1
    var toCurrencyFlag = 0
    var toCurrentPickerItem: String?
    var fromCurrentPickerItem: String?
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        cryptoCoinsPicker.dataSource = self
        cryptoCoinsPicker.delegate = self
        coinManager.delegate = self
    }
    
    @IBAction func fromCurrencyButtonClicked(_ sender: UIButton) {
        fromCurrencyFlag = 1
        toCurrencyFlag = 0
        self.cryptoCoinsPicker.reloadAllComponents()
        if let fromCurrentValue = fromCurrentPickerItem{
            fromCurrencyConverterButton.setTitle(fromCurrentValue, for: .normal)
        }
        convert()
    }
    
    @IBAction func toCurrencyButtonClicked(_ sender: UIButton) {
        fromCurrencyFlag = 0
        toCurrencyFlag = 1
        toCurrencyConverterTextField.text = ""
        if let toCurrentValue = toCurrentPickerItem{
            toCurrencyConverterButton.setTitle(toCurrentValue, for: .normal)
        }
        self.cryptoCoinsPicker.reloadAllComponents()
        convert()
    }
    
    func didConvertCoinValues( coin: CoinModel) {
        DispatchQueue.main.async {
            if let conversionValue = coin.convertTo{
                self.toCurrencyConverterTextField.text = String(format: "%2f", conversionValue)
            }
        }
    }
    
    func didUpdateWithError(error: Error) {
        print("The error is \(error.localizedDescription)")
        let alert = UIAlertController(title: "Unable to convert", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        DispatchQueue.main.async {
            alert.addAction(action)
            alert.message = error.localizedDescription
            self.present(alert, animated: true)
        }
    }
    
    func didUpdateWithParseError(coin: CoinModel) {
        let alert = UIAlertController(title: "Unable to convert", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        DispatchQueue.main.async {
            alert.addAction(action)
            alert.message = coin.error_message
            self.present(alert, animated: true)
        }
    }
    
}

extension CurrencyConverterViewController: UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        fromCurrencyConverterTextField.endEditing(true)
        convert()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fromCurrencyConverterTextField.endEditing(true)
        toCurrencyConverterTextField.endEditing(true)
        return true
    }
}

extension CurrencyConverterViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if fromCurrencyFlag == 1{
            return coinManager.cryptoCoins.count
        }else {
            return coinManager.fiatCurrency.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if fromCurrencyFlag == 1{
            fromCurrentPickerItem = coinManager.cryptoCoins[row]
            return coinManager.cryptoCoins[row]
        }else {
            toCurrentPickerItem = coinManager.fiatCurrency[row]
            return coinManager.fiatCurrency[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if fromCurrencyFlag == 1 {
            fromCurrencyConverterButton.setTitle(coinManager.cryptoCoins[row], for: .normal)
            fromCurrentPickerItem = coinManager.cryptoCoins[row]
        }else {
            toCurrencyConverterButton.setTitle(coinManager.fiatCurrency[row], for: .normal)
            toCurrentPickerItem = coinManager.fiatCurrency[row]
        }
        toCurrencyConverterTextField.text = ""
        convert()
    }
    
    func convert() {
        if let amount = self.fromCurrencyConverterTextField.text{
            if let amountValue = Double(amount){
                if let fromCurrency = fromCurrencyConverterButton.currentTitle, let toCurrency = toCurrencyConverterButton.currentTitle {
                    coinManager.convertCurrencies(from: fromCurrency, to: toCurrency, value: amountValue)
                }
            }
        }
    }
}
