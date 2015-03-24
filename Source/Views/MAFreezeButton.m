//
//  MAFreezeButton.m
//
//  Created by M on 07.05.14.
//  Copyright (c) 2014. All rights reserved.
//

#import "MAFreezeButton.h"
#import "MAController.h"
#import "MAPlayerView.h"

@interface MAFreezeButton ()
{
    BOOL _isSt;
    NSTimer* _t;
    BOOL _isNext;
    
    float _p;
    float _d;
}
@end

//=================================================================================

@implementation MAFreezeButton

//---------------------------------------------------------------------------------
- (id)initWithFrame: (CGRect)frame isNext: (BOOL)isNext
{
    if (self = [super initWithFrame: frame])
    {
        _isNext = isNext;
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)onStart
{
    _p = [[MAPlayerView sharedInstance] progress];
    _d = [[MAPlayerView sharedInstance] dur];
    _isSt = YES;
    [_t invalidate];
    [_t release];
    [[MAPlayerView sharedInstance] setIsFreeze: YES];
    _t = [[NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector(onTimer) userInfo: nil repeats: YES] retain];
}

//---------------------------------------------------------------------------------
- (void)onTimer
{
    if (_isNext)
    {
        _p += 5;
        if (_p == _d) return;
    } else {
        if (!_p) return;
        _p -= 5;
        if (_p < 0) _p = 0;
    }
    [MA_CONTROLLER stepTrack: _p];
}

//---------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isSt = NO;
    [self performSelector: @selector(onStart) withObject: nil afterDelay: 1];
}

//---------------------------------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[MAPlayerView sharedInstance] setIsFreeze: NO];
    [_t invalidate];
    [_t release];
    _t = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget: self];
    [super touchesEnded: touches withEvent: event];
    if (!_isSt)
    {
        if (_isNext)
        {
            [MA_CONTROLLER nextTrack];
        } else {
            [MA_CONTROLLER previousTrack];
        }
    }
}

@end
