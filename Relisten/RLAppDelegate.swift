//
//  RLAppDelegate.swift
//  Relisten
//
//  Created by Alec Gorge on 9/10/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

import Foundation
import Cocoa

class RLAppDelegate : NSObject, NSApplicationDelegate {
    @IBOutlet weak var window : NSWindow
    
    @IBOutlet weak var uiLoadingIndicator : NSProgressIndicator
    @IBOutlet weak var uiYearsTable : NSTableView
    @IBOutlet weak var uiArtistsDropdown : NSPopUpBUtton
    @IBOutlet weak var uiShowsTable : NSTableView
    @IBOutlet weak var uiShowTable : NSTableView
    @IBOutlet weak var uiPlaybackControlsView : NSView
    
    @IBOutlet var yearsDataSourceDelegate : RLYearsTableDataSource
    @IBOutlet var showsDataSourceDelegate : RLYearTableDataSource
    @IBOutlet var artistsManager : RLArtistDropdownManager
    @IBOutlet var showDataSourceDelegate : RLShowTableDataSource
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        DDLog.addLogger(DDASLLogger.sharedInstance())
    }
}