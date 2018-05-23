//
//  ExtractKanmusu.swift
//  ExtractKanMusu
//
//  Created by Hori,Masaki on 2017/08/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation


enum ExtractKanmusu: Error {
    
    case commandNotFound
    
    case commandError(Int32)
}

func extractKanmusu(swf: URL, to dir: URL) throws {
    
    guard let divider = Bundle.main.path(forResource: "KanColleGraphicDivider", ofType: nil)
        else {
            
            throw ExtractKanmusu.commandNotFound
    }
    
    let process = Process()
    process.launchPath = divider
    
    process.arguments = [
        "-s",
        "-o",
        "\(dir.path)",
        "-c",
        "17,19",
        swf.path
    ]
    
    process.launch()
    
    process.waitUntilExit()
    
    guard process.terminationStatus == 0 else {
        
        throw ExtractKanmusu.commandError(process.terminationStatus)
    }
}
