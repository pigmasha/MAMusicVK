//
//  MAAppDelegate.m
//
//  Created by M on 01.05.14.
//  Copyright (c) 2014. All rights reserved.
//

#import "MAAppDelegate.h"
#import "MAController.h"
#import <AVFoundation/AVFoundation.h>

@interface MAAppDelegate ()
{
    UIWindow* _window;
}
@end

//=================================================================================

@implementation MAAppDelegate

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_window release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (BOOL)application: (UIApplication*)application didFinishLaunchingWithOptions: (NSDictionary*)launchOptions
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    _window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    [MA_CONTROLLER loadInWindow: _window];
    [_window makeKeyAndVisible];
    
    return YES;
}

//---------------------------------------------------------------------------------
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    if (receivedEvent.type == UIEventTypeRemoteControl)
    {
        switch (receivedEvent.subtype)
        {
            case UIEventSubtypeRemoteControlPlay:
                [MA_CONTROLLER onPlayRem];
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [MA_CONTROLLER onPauseRem];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [MA_CONTROLLER onPlay];
                break;
            
            case UIEventSubtypeRemoteControlPreviousTrack:
                [MA_CONTROLLER previousTrack];
                break;
            
            case UIEventSubtypeRemoteControlNextTrack:
                [MA_CONTROLLER nextTrack];
                break;
            
            default: break;
        }
    }
}

@end
