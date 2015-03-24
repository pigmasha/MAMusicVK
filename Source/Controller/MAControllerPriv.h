//
//  MAControllerPriv.h
//  MAMusicVK
//
//  Created by M on 26.11.14.
//  Copyright (c) 2014. All rights reserved.
//

typedef enum
{
    DwnlNone,
    DwnlLoading,
    DwnlErr
} DwnlStep;

@class MPMoviePlayerController;
@class MAViewController;
@class MAVK;

@interface MAController ()
{
    NSMutableArray* _songs;
    
    MAVK* _item2;
    MAVK* _item3;
    
    BOOL _vkErr;
    
    NSString* _folder;
    
    MAViewController*  _vc;
    
    MPMoviePlayerController* _player;
    NSDictionary* _playSong;
    BOOL _playStop;
    BOOL _playList;
    BOOL _playErr;
    NSTimer* _playTimer;
    
    NSMutableArray* _lists;
    NSDictionary*   _list;
    NSMutableArray* _listSongs;
    NSMutableDictionary* _aids;
    NSTimeInterval _urlsTime;
    
    NSNumber* _o;
    
    BOOL _useL;
}

- (void)songsSave;

@end

