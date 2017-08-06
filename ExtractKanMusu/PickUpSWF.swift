//
//  PickUpSWF.swift
//  ExtractKanMusu
//
//  Created by Hori,Masaki on 2017/08/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation


enum PickUPSWFError: Error {
    
    case scriptNotFound
    case commandFail(Int32)
}


func pickUpSWF(from origin: URL, to copy: URL) throws {
    
    let pickup = Bundle.main.path(forResource: "pickup", ofType: "rb")
    guard let pickupPath = pickup
        else { throw PickUPSWFError.scriptNotFound }
    
    let process = Process()
    process.currentDirectoryPath = origin.path
    process.launchPath = "/usr/bin/ruby"
    process.arguments = [pickupPath]
    
    process.launch()
    process.waitUntilExit()
    
    guard process.terminationStatus == 0
        else { throw PickUPSWFError.commandFail(process.terminationStatus) }
    
}
