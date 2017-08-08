//
//  ViewController.swift
//  ExtractKanMusu
//
//  Created by Hori,Masaki on 2017/08/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let progress = ProgressPanelController()
    
    var chuuchuu: ChuuChuu?
    
    
    @IBOutlet var cachePathField: NSPathControl!
    @IBOutlet var outputFolderField: NSPathControl!
    
    dynamic var maxPower = false
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        cachePathField.url = ApplicationDirecrories.support
            .appendingPathComponent("com.masakih.KCD")
            .appendingPathComponent("Caches")
        
        outputFolderField.url = ApplicationDirecrories.desctop
        
    }
    
}


extension ViewController {
    
    private func chooseFolder(prompt: String, current: URL?, handler: @escaping (URL?) -> Void) {
        
        let panel = NSOpenPanel()
        
        panel.prompt = prompt
        panel.directoryURL = current
        
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.resolvesAliases = true
        
        let window = self.view.window!
        
        panel.beginSheetModal(for: window) {
            
            guard $0 == NSFileHandlingPanelOKButton else { return }
            
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
    
    @IBAction func extract(_ : Any?) {
        
        guard let original = cachePathField.url else {
            
            print("CachPath is nil.")
            
            return
        }
        
        guard let dest = outputFolderField.url else {
            
            print("outputPath is nil.")
            
            return
        }
        
        chuuchuu = ChuuChuu(observer: progress, original: original, destination: dest)
        
        self.view.window?.beginSheet(progress.window!, completionHandler: nil)
        
        chuuchuu?.execute(maxPower: maxPower) { [weak self] in
            
            guard let `self` = self else { return }
            
            self.view.window?.endSheet(self.progress.window!)
        }
        
    }
}
