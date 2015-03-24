//
//  MAPlayerView.m
//  MAMusicVK
//
//  Created by M on 02.03.15.
//  Copyright (c) 2015. All rights reserved.
//

#import "MAPlayerView.h"
#import "MAController.h"
#import "MAFreezeButton.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MAPlayerView ()
{
    UILabel* _time;
    UILabel* _title;
    UILabel* _artist;
    UIButton* _playBt;
    BOOL _isFreeze;
    
    float _p;
    float _d;
}

@end

//=================================================================================

@implementation MAPlayerView

static MAPlayerView* _s_inst = nil;

+ (MAPlayerView*)sharedInstance
{
    return _s_inst;
}

//---------------------------------------------------------------------------------
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame: frame])
    {
        self.backgroundColor = [UIColor colorWithWhite: 0.9 alpha: 1];
        self.autoresizingMask = SZ(Width) | SZ_M(Top);
        
        ADD_LABEL(_title, 10, 0, frame.size.width - 20, 50, SZ_M(Top) | SZ(Width), 18, YES, self);
        _title.textAlignment = UITextAlignmentCenter;
        _title.numberOfLines = 0;
        
        ADD_LABEL(_time, 10, 55, 100, 20, SZ_M(Top), 13, NO, self);
        
        _playBt = [[UIButton alloc] initWithFrame: CGRectMake((frame.size.width - PLAY_BT_SZ) / 2 + 50, 50, PLAY_BT_SZ, PLAY_BT_SZ)];
        [_playBt setImage: [UIImage imageNamed: @"play"] forState: UIControlStateNormal];
        [_playBt addTarget: MA_CONTROLLER action: @selector(onPlay) forControlEvents: UIControlEventTouchDown];
        _playBt.autoresizingMask = SZ_M(Top) | SZ_M(Left) | SZ_M(Right);
        [self addSubview: _playBt];
        [_playBt release];
        
        MAFreezeButton* b1 = [[MAFreezeButton alloc] initWithFrame: CGRectMake((frame.size.width - PLAY_BT_SZ) / 2 - 50 + 50, 50, PLAY_BT_SZ, PLAY_BT_SZ) isNext: NO];
        [b1 setImage: [UIImage imageNamed: @"play_p"] forState: UIControlStateNormal];
        b1.autoresizingMask = SZ_M(Left);
        [self addSubview: b1];
        [b1 release];
        
        b1 = [[MAFreezeButton alloc] initWithFrame: CGRectMake((frame.size.width - PLAY_BT_SZ) / 2 + 50 + 50, 50, PLAY_BT_SZ, PLAY_BT_SZ) isNext: YES];
        [b1 setImage: [UIImage imageNamed: @"play_n"] forState: UIControlStateNormal];
        b1.autoresizingMask = SZ_M(Left);
        [self addSubview: b1];
        [b1 release];
        
        MPVolumeView* vol = [[MPVolumeView alloc] initWithFrame: self.bounds];
        vol.autoresizingMask = SZ(Width);
        [vol sizeToFit];
        vol.frame = CGRectMake(50, 90, frame.size.width - 100, vol.bounds.size.height);
        [self addSubview: vol];
        [vol release];
        
        UIImage* i = [UIImage imageNamed: @"vol_off"];
        UIImageView* v = [[UIImageView alloc] initWithFrame: CGRectMake(50 - i.size.width, 86, i.size.width, i.size.height)];
        v.image = i;
        [self addSubview: v];
        [v release];
        
        i = [UIImage imageNamed: @"vol_on"];
        v = [[UIImageView alloc] initWithFrame: CGRectMake(frame.size.width - 40, 86, i.size.width, i.size.height)];
        v.image = i;
        [self addSubview: v];
        [v release];
        
        [self reloadData];
        
        _s_inst = self;
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    if (_s_inst == self) _s_inst = nil;
    [super dealloc];
}

//---------------------------------------------------------------------------------
// return dur
//---------------------------------------------------------------------------------
- (int)reloadData
{
    NSDictionary* song = [MA_CONTROLLER song];
    if (!song) song = [MA_CONTROLLER listSong];
    _title.text  = (song) ? [song objectForKey: SONG_TITLE] : @"";
    _artist.text = (song) ? [song objectForKey: SONG_ARTIST] : @"";
    
    _d = [[song objectForKey: SONG_DUR] intValue];
    NSString* str = [[NSString alloc] initWithFormat: LSTR(@"P_Prog"), 0, 0, (int)_d / 60, (int)_d % 60];
    _time.text = str;
    [str release];
    
    return _d;
}

//---------------------------------------------------------------------------------
- (void)reloadTime
{
    MPMoviePlayerController* p = [MA_CONTROLLER player];
    if (!p || _isFreeze || isnan(p.currentPlaybackTime))
    {
        _p = 0;
        return;
    }
    
    _p = p.currentPlaybackTime;
    NSString* str = [[NSString alloc] initWithFormat: LSTR(@"P_Prog"), (int)p.currentPlaybackTime / 60, (int)p.currentPlaybackTime % 60, (int)_d / 60, (int)_d % 60];
    _time.text = str;
    [str release];
}

//---------------------------------------------------------------------------------
// return isStop
//---------------------------------------------------------------------------------
- (BOOL)reloadState
{
    MPMoviePlayerController* player = [MA_CONTROLLER player];
    if (!player) return YES;
    
    [self reloadTime];
    
    BOOL isStop = (player.playbackState != MPMoviePlaybackStatePlaying
                   && player.playbackState != MPMoviePlaybackStateSeekingForward
                   && player.playbackState != MPMoviePlaybackStateSeekingBackward
                   && ![MA_CONTROLLER playErr]);
    
    [_playBt setImage: [UIImage imageNamed: (isStop) ? @"play" : @"pause"] forState: UIControlStateNormal];
    return isStop;
}

//---------------------------------------------------------------------------------
- (void)setIsFreeze: (BOOL)isFreeze
{
    _isFreeze = isFreeze;
}

//---------------------------------------------------------------------------------
- (BOOL)isFreeze
{
    return _isFreeze;
}

//---------------------------------------------------------------------------------
- (float)progress
{
    return _p;
}

//---------------------------------------------------------------------------------
- (float)dur
{
    return _d;
}

@end
