//
//  ViewController.swift
//  ExtractKanMusu
//
//  Created by Hori,Masaki on 2017/08/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

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

class ViewController: NSViewController {
    
    static let chuchu = "ちゅーちゅー"
    static let tempDirName = "___temp_chu-chu-_ship___"
    
    @IBOutlet var cachePathField: NSPathControl!
    @IBOutlet var outputFolderField: NSPathControl!
    
    dynamic var maxPower = false
    
    var useCoreCount: Int {
        
        let coreCount = ProcessInfo.processInfo.processorCount
        
        return maxPower ? coreCount : coreCount / 2
    }
    
    let progress = ProgressPanelController()

    override func viewDidLoad() {
        
        super.viewDidLoad()

        cachePathField.url = ApplicationDirecrories.support
            .appendingPathComponent("com.masakih.KCD")
            .appendingPathComponent("Caches")
        
        outputFolderField.url = ApplicationDirecrories.desctop
        
    }
    
}


extension ViewController {
    
    func chooseFolder(prompt: String, current: URL?, handler: @escaping (URL?) -> Void) {
        
        let panel = NSOpenPanel()
        
        panel.prompt = prompt
        panel.directoryURL = current
        
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.resolvesAliases = true
        
        let window = self.view.window!
        
        panel.beginSheetModal(for: window) {
            
            guard $0 == NSFileHandlingPanelOKButton
                else { return }
            
            handler(panel.url)
            
            panel.endSheet(window)
        }
        
    }
    
    @IBAction func chooseCacheFolder(_ : Any?) {
        
        chooseFolder(prompt: "Choose Cache Folder", current: cachePathField.url) {
            
            guard let url = $0 else { return }
            self.cachePathField.url = url
        }
        
    }
    
    @IBAction func chooseOutputFolder(_ : Any?) {
        
        chooseFolder(prompt: "Choose Output Folder", current: outputFolderField.url) {
            
            guard let url = $0 else { return }
            self.outputFolderField.url = url
        }
        
    }
    
    enum ExtractKanMusu: Error {
        
        case urlMissing(String)
    }
    func createTempDir() throws {
        
        guard let tempParentURL = cachePathField.url else {
            
            throw ExtractKanMusu.urlMissing("Cache dir is nil")
        }
        
        let tempURL = tempParentURL.appendingPathComponent(ViewController.tempDirName)
        
        try FileManager.default
            .createDirectory(at: tempURL, withIntermediateDirectories: true, attributes: nil)
        
    }
    
    func deleteTempDir() throws {
        
        guard let tempParentURL = cachePathField.url else {
            
            throw ExtractKanMusu.urlMissing("Cache dir is nil")
        }
        
        let tempURL = tempParentURL.appendingPathComponent(ViewController.tempDirName)
        
        try FileManager.default.removeItem(at: tempURL)
    }
    
    func createDestDir() throws {
        
        guard let destParentURL = outputFolderField.url else {
            
            throw ExtractKanMusu.urlMissing("Output dir is nil")
        }
        
        let destURL = destParentURL.appendingPathComponent(ViewController.chuchu)
        
        try FileManager.default
            .createDirectory(at: destURL, withIntermediateDirectories: true, attributes: nil)
        
    }
    
    func moveSWF(from originalDir: URL, to destinationDir: URL) {
        
        progress.message = "Picking up SWF file from Cache Directory."
        
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
    
    
    func extractKanmusus(swfs: [URL], to destURL: URL) {
        
        progress.message = "Extracting KanMusu Image from SWF file."
        
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
                
                self.progress.appendFinished()
                
            }
            
        }
        
        group.wait()
    }
    
    
    func execute() {
        
        guard let originalDir = cachePathField.url,
            let existOriginalDir = try? originalDir.checkResourceIsReachable(),
            existOriginalDir
            else { return }
        
        guard let destinationDir = outputFolderField.url,
            let existDestinationDir = try? destinationDir.checkResourceIsReachable(),
            existDestinationDir
            else { return }
        
        self.view.window?.beginSheet(progress.window!, completionHandler: nil)
        
        do {
            
            try createTempDir()
            try createDestDir()
            
        } catch {
            
            print(error)
        }
        
        let tempURL = originalDir.appendingPathComponent(ViewController.tempDirName)
        let destURL = destinationDir.appendingPathComponent(ViewController.chuchu)
        
        DispatchQueue(label: "Nya-nn").async {
            
            do {
                self.moveSWF(from: originalDir, to: destinationDir)
                
                let swfs = try FileManager.default
                    .contentsOfDirectory(at: tempURL, includingPropertiesForKeys: nil)
                    .filter { $0.pathExtension == "swf" }
                
                self.progress.count = swfs.count
                
                self.extractKanmusus(swfs: swfs, to: destURL)
                
                DispatchQueue.main.async {
                    
                    self.view.window?.endSheet(self.progress.window!)
                }
                
                try self.deleteTempDir()
                
            } catch {
                
                print(error)
            }
        }
    }
    
    @IBAction func extract(_ : Any?) {
        
        execute()
        
    }
    
}

