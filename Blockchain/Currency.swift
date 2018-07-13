//
//  Currency.swift
//  Blockchain
//
//  Created by Justin on 7/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

struct FiatCurrency: CustomStringConvertible {
    var name: String
    var symbol: String
    var sell: NSNumber
    var buy: NSNumber
    var last: NSNumber
    var fifteenMin: NSNumber
    var description: String { return "\(name) (\(symbol))" }
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.symbol = dictionary["symbol"] as? String ?? ""
        self.sell = dictionary["sell"] as? NSNumber ?? 0.0
        self.buy = dictionary["buy"] as? NSNumber  ?? 0.0
        self.last = dictionary["last"] as? NSNumber  ?? 0.0
        self.fifteenMin = dictionary["15m"] as? NSNumber  ?? 0.0
    }
    
    init?(data: Data) {
        guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else { return nil }
        self.init(dictionary: json)
    }
    
    init?(json: String) {
        self.init(data: Data(json.utf8))
    }
}
