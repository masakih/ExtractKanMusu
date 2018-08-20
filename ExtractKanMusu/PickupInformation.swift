//
//  PickupInformation.swift
//  ExtractKanMusu
//
//  Created by Hori,Masaki on 2018/08/19.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

struct PickupInformation: Codable {
    
    let urlString: String
    let filename: String
    
    var url: URL {
        
        return URL(string: urlString)!
    }
    
    enum CodingKeys: String, CodingKey {
        
        case urlString = "url"
        case filename
    }
}
