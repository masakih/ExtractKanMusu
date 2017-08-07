//
//  ApplicationDirecrories.swift
//  ExtractKanMusu
//
//  Created by Hori,Masaki on 2017/08/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

struct ApplicationDirecrories {
    
    static let support = searchedURL(for: .applicationSupportDirectory)
    
    static let documents = searchedURL(for: .documentDirectory)
    
    static let pictures = searchedURL(for: .picturesDirectory)
    
    static let desctop = searchedURL(for: .desktopDirectory)
    
    private static func searchedURL(for directory: FileManager.SearchPathDirectory) -> URL {
        
        return FileManager.default.urls(for: directory, in: .userDomainMask)
            .last
            ?? URL(fileURLWithPath: NSHomeDirectory())
    }
}
