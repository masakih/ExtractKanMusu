//
//  ProgressPanelController.swift
//  ExtractKanMusu
//
//  Created by Hori,Masaki on 2017/08/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class ProgressPanelController: NSWindowController {
    
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
    
    private dynamic var finished: Int = 0 {
        
        didSet {
            
            willChangeValue(forKey: #keyPath(progresString))
            
            didChangeValue(forKey: #keyPath(progresString))
        }
    }
    
    private dynamic var progresString: String {
        
        get {
            
            if count == 0 {
                return ""
            }
            
            let parcent = Int( Double(finished) / Double(rawCount) * 100 )
            
            return "\(finished)/\(rawCount) (\(parcent)%)"
            
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
    
    dynamic var font: NSFont {
        
        let size = NSFont.systemFontSize()
        return NSFont.monospacedDigitSystemFont(ofSize: size, weight: NSFontWeightRegular)
    }
    
    
    override var windowNibName: String? {
        
        return "ProgressPanelController"
    }
    
    func appendFinished() {
        
        DispatchQueue.main.async {
            
            self.finished += 1
        }
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
    }
    
}
