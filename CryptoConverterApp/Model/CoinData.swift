//
//  CoinData.swift
//  CryptoConverterApp
//
//  Created by admin on 22/08/20.
//  Copyright © 2020 suhas. All rights reserved.
//

import Foundation
import SwiftyJSON


struct CoinData: Decodable {
    let data: DataKeyContents?
    let status: StatusKeyContents
}

struct DataKeyContents: Decodable {
    let id: Int
    let symbol: String
    let amount: Int
    let quote: JSON
}

struct StatusKeyContents: Decodable {
    let error_code: Int
    let error_message: String?
}
