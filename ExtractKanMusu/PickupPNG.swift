//
//  PickupPNG.swift
//  ExtractKanMusu
//
//  Created by Hori,Masaki on 2017/08/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation


enum PickupPNGError: Error {
    
    case scriptNotFound
    case commandFail(Int32)
}


func getPickUpInformations(from origin: URL) throws -> [PickupInformation] {
    
    let pickup = Bundle.main.path(forResource: "pickup", ofType: "rb")
    guard let pickupPath = pickup else { throw PickupPNGError.scriptNotFound }
        
    let process = Process()
    process.currentDirectoryPath = origin.path
    process.launchPath = "/usr/bin/ruby"
    process.arguments = [pickupPath]
    
    let pipe = Pipe()
    process.standardOutput = pipe
    
    process.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    
    process.waitUntilExit()
    
    guard process.terminationStatus == 0 else {
        
        throw PickupPNGError.commandFail(process.terminationStatus)
    }
    
    return try JSONDecoder().decode([PickupInformation].self, from: data)
    
}
