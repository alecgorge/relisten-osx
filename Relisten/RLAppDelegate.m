//
//  RLAppDelegate.m
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "RLAppDelegate.h"

#import "AFNetworkActivityIndicatorManager.h"
#import "RLYearsTableDataSource.h"
#import "RLArtistDropdownManager.h"
#import "RLYearTableDataSource.h"
#import "RLShowTableDataSource.h"
#import "RLPlaybackManager.h"
#import "RLSourceDropdownManager.h"

#import <WebKit/WebKit.h>

@interface RLAppDelegate ()

@property (weak) IBOutlet NSProgressIndicator *uiLoadingIndicator;
@property (weak) IBOutlet NSTableView *uiYearsTable;
@property (weak) IBOutlet NSPopUpButton *uiArtistsDropdown;
@property (weak) IBOutlet NSTableView *uiShowsTable;
@property (weak) IBOutlet NSTableView *uiShowTable;
@property (weak) IBOutlet NSView *uiPlaybackControlsView;
@property (weak) IBOutlet NSPopUpButton *uiSourcesDropdown;
@property (weak) IBOutlet NSButton *uiSourceInfoButton;

@property (nonatomic, strong) RLYearsTableDataSource *yearsDataSourceDelegate;
@property (nonatomic, strong) RLYearTableDataSource *showsDataSourceDelegate;
@property (nonatomic, strong) RLArtistDropdownManager *artistsManager;
@property (nonatomic, strong) RLShowTableDataSource *showDataSourceDelegate;
@property (nonatomic, strong) RLSourceDropdownManager *sourceManager;

@end

@implementation RLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [DDLog addLogger:DDASLLogger.sharedInstance];
    [DDLog addLogger:DDTTYLogger.sharedInstance];
    
    [AFNetworkActivityIndicatorManager sharedManagerForProgressIndicator:self.uiLoadingIndicator].enabled = YES;
    
    self.artistsManager = [RLArtistDropdownManager.alloc initWithPopUpButton:self.uiArtistsDropdown];
    
    self.yearsDataSourceDelegate = [RLYearsTableDataSource.alloc initWithTableView:self.uiYearsTable];
    self.uiYearsTable.dataSource = self.yearsDataSourceDelegate;
    self.uiYearsTable.delegate = self.yearsDataSourceDelegate;
    
    self.showsDataSourceDelegate = [RLYearTableDataSource.alloc initWithTableView:self.uiShowsTable];
    self.uiShowsTable.dataSource = self.showsDataSourceDelegate;
    self.uiShowsTable.delegate = self.showsDataSourceDelegate;
    
    self.showDataSourceDelegate = [RLShowTableDataSource.alloc initWithTableView:self.uiShowTable];
    self.uiShowTable.dataSource = self.showDataSourceDelegate;
    self.uiShowTable.delegate = self.showDataSourceDelegate;
	
	self.sourceManager = [RLSourceDropdownManager.alloc initWithPopUpButton:self.uiSourcesDropdown];
	self.showDataSourceDelegate.sourceManager = self.sourceManager;
    
    RLPlaybackManager *manager = [RLPlaybackManager sharedManagerForView:self.uiPlaybackControlsView];
    [manager.trackStarted.executionSignals subscribeNext:^(RACSignal *mediaItemSignal) {
        [mediaItemSignal subscribeNext:^(AGMediaItem *mediaItem) {
            NSUserNotification *notification = NSUserNotification.alloc.init;
            notification.title = mediaItem.displayText;
            notification.informativeText = mediaItem.displaySubText;
            notification.deliveryDate = NSDate.date;
            
            [NSUserNotificationCenter.defaultUserNotificationCenter scheduleNotification:notification];
        }];
    }];
    
    [self.yearsDataSourceDelegate.yearSelected.executionSignals subscribeNext:^(RACSignal *y) {
        [y subscribeNext:^(IGYear *year) {
            [self.showsDataSourceDelegate refreshForYear:year];
        }];
    }];
    
    [self.showsDataSourceDelegate.showSelected.executionSignals subscribeNext:^(RACSignal *s) {
        [s subscribeNext:^(IGShow *show) {
			[self.sourceManager refreshForShow:show];
        }];
    }];
    
    [self.artistsManager.artistChanged.executionSignals subscribeNext:^(RACSignal *a) {
        [a subscribeNext:^(IGArtist *artist) {
            [self.yearsDataSourceDelegate refreshForArtist:artist];
            
            [NSUserDefaults.standardUserDefaults setObject:artist.slug
                                                    forKey:@"last_selected_artist_slug"];
        }];
    }];

    [self.artistsManager refresh];
}

- (IBAction)viewSourceInfo:(NSButton *)sender {
    NSPopover *popover = NSPopover.alloc.init;
    NSViewController *vc = NSViewController.alloc.init;
    vc.view = [NSView.alloc initWithFrame:NSMakeRect(0, 0, 500, 250)];
    
    WebView *v = [WebView.alloc initWithFrame:vc.view.bounds];
    [v.mainFrame loadHTMLString:self.sourceManager.currentSource.htmlSummary
                        baseURL:[NSURL URLWithString:@"http://relisten.net"]];
    
    [vc.view addSubview:v];
    
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = NSMakeSize(500, 250);
    popover.contentViewController = vc;
    popover.animates = YES;
    [popover showRelativeToRect:NSZeroRect
                         ofView:sender
                  preferredEdge:NSMaxYEdge];
}

@end
