//
//  MAControllerVK.m
//
//  Created by M on 04.05.14.
//  Copyright (c) 2014. All rights reserved.
//

#import "MAController.h"
#import "MAControllerPriv.h"
#import "MAControllerVK.h"
#import "MAViewController.h"
#import "MAVK.h"

#import "MAConstants.h"

@implementation MAController (VKUtils)

//---------------------------------------------------------------------------------
- (void)vkSearch: (NSString*)text
{
    [_vc setLoading: YES];
    [_item2 act: text];
}

//---------------------------------------------------------------------------------
- (BOOL)vkLogined
{
    return ([[NSUserDefaults standardUserDefaults] objectForKey: SETT_VK_ID] != nil);
}

//---------------------------------------------------------------------------------
- (void)vkLogin
{
    _vkErr = NO;
}

//---------------------------------------------------------------------------------
- (void)vkClose
{
    if (_vkErr)
    {
        SHOW_ALERT(LSTR(@"Error"), LSTR(@"Err_VK"))
        _vkErr = NO;
    }
    
    [_vc vkClose];
}

//---------------------------------------------------------------------------------
- (void)vkLogout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: SETT_VK_ID];
    [_vc reloadData];
}

//---------------------------------------------------------------------------------
+ (BOOL)vkWebAnswer: (NSString*)str isClose: (BOOL)isClose
{
    NSRange r1 = [str rangeOfString: @"access_token="];
    if (!r1.length) return NO;
    
    r1.location += r1.length;
    
    NSRange r2 = [str rangeOfString: @"&" options: 0 range: NSMakeRange(r1.location, [str length] - r1.location)];
    if (r2.length)
    {
        [[NSUserDefaults standardUserDefaults] setObject: [str substringWithRange: NSMakeRange(r1.location, r2.location - r1.location)] forKey: SETT_VK_TOKEN];
    }
    
    r1 = [str rangeOfString: @"&user_id=" options: NSBackwardsSearch];
    if (r1.length)
    {
        r1.location += r1.length;
        [[NSUserDefaults standardUserDefaults] setObject: [str substringWithRange: NSMakeRange(r1.location, [str length] - r1.location)] forKey: SETT_VK_ID];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (isClose) [[self sharedInstance] performSelectorOnMainThread: @selector(vkClose) withObject: nil waitUntilDone: NO];
    return YES;
}

//---------------------------------------------------------------------------------
- (void)vkWebError: (NSError *)error
{
    _vkErr = YES;
    [self performSelectorOnMainThread: @selector(vkClose) withObject: nil waitUntilDone: NO];
}

//---------------------------------------------------------------------------------
- (void)vkResult: (MAVK*)sender hasNext: (BOOL)hasNext
{
    if (sender->_isErr)
    {
        [self vkLogout];
        return;
    }
    
    switch (sender->_type)
    {
        case VKSearch:
            [_songs removeAllObjects];
            [_songs addObjectsFromArray: sender->_items];
            [self songsSave];
            [_vc reloadData];
            if (!hasNext) [_vc setLoading: NO];
            break;
        case VKUrls:
            if (!sender->_nonActual) [self songsUrls: sender->_items];
            break;
    }
}

@end
