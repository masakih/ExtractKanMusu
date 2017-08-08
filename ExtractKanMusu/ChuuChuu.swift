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

class ChuuChuu {
    
    static let chuchu = "ちゅーちゅー"
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
    
    
    private func createTempDir() throws {
        
        let tempURL = originalDir.appendingPathComponent(ChuuChuu.tempDirName)
        
        try FileManager.default
            .createDirectory(at: tempURL, withIntermediateDirectories: true, attributes: nil)
        
    }
    
    private func deleteTempDir() throws {
        
        let tempURL = originalDir.appendingPathComponent(ChuuChuu.tempDirName)
        
        try FileManager.default.removeItem(at: tempURL)
    }
    
    private func createDestDir() throws {
        
        let destURL = destinationDir.appendingPathComponent(ChuuChuu.chuchu)
        
        try FileManager.default
            .createDirectory(at: destURL, withIntermediateDirectories: true, attributes: nil)
        
    }
    
    private func moveSWF(from originalDir: URL, to destinationDir: URL) {
        
        observer.message = "Picking up SWF file from Cache Directory."
        
        do {
            
            try pickUpSWF(from: originalDir, to: destinationDir)
            
        } catch {
            
            print("Can not pickup.", terminator: " : ")
            
            guard let error = error as? PickUPSWFError else {
                
                print("Unkown error.")
                return
            }
            
            switch error {
            case .scriptNotFound: print("Script not found.")
                
            case let .commandFail(status): print("Command faile status \(status).")
            }
        }
    }
    
    private func extractKanmusus(swfs: [URL], to destURL: URL) {
        
        observer.message = "Extracting KanMusu Image from SWF file."
        
        let semaphone = DispatchSemaphore(value: useCoreCount)
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "extract", attributes: .concurrent)
        
        swfs.forEach { swf in
            
            queue.async(group: group) {
                
                semaphone.wait()
                
                do {
                    
                    try extractKanmusu(swf: swf, to: destURL)
                    
                } catch {
                    
                    print(error)
                }
                
                semaphone.signal()
                
                self.observer.increse()
                
            }
            
        }
        
        group.wait()
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
                
                try self.createTempDir()
                try self.createDestDir()
                
                self.moveSWF(from: self.originalDir, to: self.destinationDir)
                
                let tempURL = self.originalDir.appendingPathComponent(ChuuChuu.tempDirName)
                let destURL = self.destinationDir.appendingPathComponent(ChuuChuu.chuchu)
                
                let swfs = try FileManager.default
                    .contentsOfDirectory(at: tempURL, includingPropertiesForKeys: nil)
                    .filter { $0.pathExtension.lowercased() == "swf" }
                
                self.observer.count = swfs.count
                
                self.extractKanmusus(swfs: swfs, to: destURL)
                
                try self.deleteTempDir()
                
            } catch {
                
                print(error)
            }
            
            DispatchQueue.main.async {
                
                completeHandler()
            }
        }
    }
    
}
