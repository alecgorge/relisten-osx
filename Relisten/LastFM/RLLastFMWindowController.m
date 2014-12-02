//
//  RLLastFMWindowController.m
//  Relisten
//
//  Created by Alec Gorge on 12/2/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "RLLastFMWindowController.h"

#import <LastFm/LastFm.h>

@interface RLLastFMWindowController ()

@property (weak) IBOutlet NSTextField *uiUsernameField;
@property (weak) IBOutlet NSSecureTextField *uiPasswordField;
@property (weak) IBOutlet NSButton *uiSignInButton;
@property (weak) IBOutlet NSButton *uiCancelButton;

@property (nonatomic) NSWindow *parentWindow;

@end

@implementation RLLastFMWindowController

- (instancetype)initWithParentWindow:(NSWindow *)window {
	if (self = [super initWithWindowNibName:NSStringFromClass(RLLastFMWindowController.class)]) {
		self.parentWindow = window;
	}
	
	return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
	
	self.uiSignInButton.target = self;
	self.uiSignInButton.action = @selector(uiSignIn:);
	
	self.uiCancelButton.target = self;
	self.uiCancelButton.action = @selector(uiCancel:);
	
    if (LastFm.sharedInstance.username) {
        self.uiUsernameField.stringValue = LastFm.sharedInstance.username;
        
        self.uiSignInButton.title = @"Sign Out";
    }
}

- (IBAction)uiCancel:(id)sender {
	[self.parentWindow endSheet:self.window];
}

- (IBAction)uiSignIn:(id)sender {
    if(LastFm.sharedInstance.username) {
        [LastFm.sharedInstance logout];
        
        [NSUserDefaults.standardUserDefaults removeObjectForKey:@"lastfm_session_key"];
        [NSUserDefaults.standardUserDefaults removeObjectForKey:@"lastfm_username_key"];
        
        [self uiCancel:nil];
        return;
    }
    
    [[LastFm sharedInstance] getSessionForUser:self.uiUsernameField.stringValue
                                      password:self.uiPasswordField.stringValue
                                successHandler:^(NSDictionary *result) {
                                    // Save the session into NSUserDefaults. It is loaded on app start up in AppDelegate.
                                    [[NSUserDefaults standardUserDefaults] setObject:result[@"key"] forKey:@"lastfm_session_key"];
                                    [[NSUserDefaults standardUserDefaults] setObject:result[@"name"] forKey:@"lastfm_username_key"];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                    
                                    // Also set the session of the LastFm object
                                    [LastFm sharedInstance].session = result[@"key"];
                                    [LastFm sharedInstance].username = result[@"name"];
                                    
									[self uiCancel:self];
                                }
                                failureHandler:^(NSError *error) {
									NSAlert *a = [NSAlert alertWithError:error];
									[a runModal];
                                }];
}

@end
