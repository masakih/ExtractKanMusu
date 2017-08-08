//
//  ProgressPanelController.swift
//  ExtractKanMusu
//
//  Created by Hori,Masaki on 2017/08/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class ProgressPanelController: NSWindowController, MessageObserver {
    
    override var windowNibName: String? {
        
        return "ProgressPanelController"
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
    }
    
    private dynamic var rawCount: Int = 0 {
        
        didSet {
            
            willChangeValue(forKey: #keyPath(progresString))
            
            didChangeValue(forKey: #keyPath(progresString))
            
        }
    }
    var count: Int = 0 {
        
        didSet {
            
            DispatchQueue.main.async {
                
                self.rawCount = self.count
            }
        }
    }
    
    private dynamic var completed: Int = 0 {
        
        didSet {
            
            willChangeValue(forKey: #keyPath(progresString))
            
            didChangeValue(forKey: #keyPath(progresString))
        }
    }
    
    private dynamic var rawMessage: String = ""
    var message: String = "" {
        
        didSet {
            
            DispatchQueue.main.async {
                
                self.rawMessage = self.message
            }
            
        }
    }
    
    private dynamic var progresString: String {
        
        get {
            
            if count == 0 {
                return ""
            }
            
            let parcent = Int( Double(completed) / Double(rawCount) * 100 )
            
            return "\(completed)/\(rawCount) (\(parcent)%)"
            
        }
    }
    
    private dynamic var font: NSFont {
        
        let size = NSFont.systemFontSize()
        return NSFont.monospacedDigitSystemFont(ofSize: size, weight: NSFontWeightRegular)
    }
    
    func increse() {
        
        DispatchQueue.main.async {
            
            self.completed += 1
        }
    }
    
}
