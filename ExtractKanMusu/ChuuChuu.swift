//
//  ChuuChuu.swift
//  ExtractKanMusu
//
//  Created by Hori,Masaki on 2017/08/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation


protocol MessageObserver: class {
    
    var message: String { get set }
    
    var count: Int { get set }
    
    func increse()
}

private enum  ImageType: String {
    
    case full
    
    case full_dmg
}

class ChuuChuu {
    
    static let chuchu = "ちゅーちゅー2"
    static let tempDirName = "___temp_chu-chu-_ship___"
    
    let observer: MessageObserver
    let originalDir: URL
    let destinationDir: URL
    
    private var maxPower = false
    private var useCoreCount: Int {
        
        let coreCount = ProcessInfo.processInfo.processorCount
        
        return maxPower ? coreCount : coreCount / 2
    }
    
    init(observer: MessageObserver, original: URL, destination: URL) {
        
        self.observer = observer
        originalDir = original
        destinationDir = destination
    }
    
    private func createDestDir() throws {
        
        let destURL = destinationDir.appendingPathComponent(ChuuChuu.chuchu)
        
        try FileManager.default
            .createDirectory(at: destURL, withIntermediateDirectories: true, attributes: nil)
        
    }
    
    private func movePNG(from originalDir: URL, to destinationDir: URL) {
        
        observer.message = "Checking Cache Directory."
        
        do {
            
            let informations = try getPickUpInformations(from: originalDir)
            
            observer.message = "Picking up PNG file from Cache Directory."
            
            observer.count = informations.count
            
            let fm = FileManager.default
            
            try informations
                .compactMap { info -> (URL, URL)? in
                    
                    observer.increse()
                    
                    let url = info.url
                    let name = url.deletingPathExtension().lastPathComponent
                    guard let type = url.deletingPathExtension().pathComponents.dropLast().last else { return nil }
                    guard let _ = ImageType(rawValue: type) else { return nil }
                    guard let id = Int(name.prefix(4)), id < 1500 else { return nil }
                    
                    let destFilename: String
                    if let query = url.query {
                        
                        destFilename = type + "-" + name + "_" + query
                        
                    } else {
                        
                        destFilename = type + "-" + name
                    }
                    
                    let destination = destinationDir
                        .appendingPathComponent(ChuuChuu.chuchu)
                        .appendingPathComponent(destFilename)
                        .appendingPathExtension("png")
                    
                    let original = originalDir
                        .appendingPathComponent("fsCachedData")
                        .appendingPathComponent(info.filename)
                    
                    return (destination, original)
                    
                }
                .filter { destination, _ in
                    
                    (try? !destination.checkResourceIsReachable()) ?? true
                    
                }
                .forEach { destination, original in
                    
                    try fm.copyItem(at: original, to: destination)
            }
            
        } catch let error as PickupPNGError {
            
            switch error {
            case .scriptNotFound: print("Script not found.")
                
            case let .commandFail(status): print("Command faile status \(status).")
            }
            
        } catch {
            
            print("Can not pickup.", terminator: " : ")
            
            print("Unkown error.", error)
        }
    }
    
    func execute(maxPower: Bool, completeHandler: @escaping () -> Void) {
        
        guard let existOriginalDir = try? originalDir.checkResourceIsReachable(),
            existOriginalDir else {
                
                completeHandler()
                return
        }
        
        guard let existDestinationDir = try? destinationDir.checkResourceIsReachable(),
            existDestinationDir else {
                
                completeHandler()
                return
        }
        
        self.maxPower = maxPower
        
        
        DispatchQueue(label: "Nya-nn").async {
            
            do {
                
                try self.createDestDir()
                
                self.movePNG(from: self.originalDir, to: self.destinationDir)
                
            } catch {
                
                print(error)
            }
            
            DispatchQueue.main.async {
                
                completeHandler()
            }
        }
    }
    
}
