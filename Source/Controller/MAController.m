//
//  MAController.m
//
//  Created by M on 01.05.14.
//  Copyright (c) 2014. All rights reserved.
//

#import "MAController.h"
#import "MAControllerPriv.h"
#import "MAControllerVK.h"
#import "MAVK.h"

#import "MAConstants.h"
#import "MAProgressView.h"
#import "MAViewController.h"
#import "MAPlayerView.h"
#import "MASongCell.h"

#import "MASettController.h"
#import "MAListsController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreText/CoreText.h>

#define FILE_SONGS @"%@/songs.plist"
#define FILE_LISTS @"lists.plist"
#define FILE_LIST_FMT @"%@/list_%d.plist"

#define URLS_OLD_TIME 3600

#define CREATE_FOLDER(__path) if (![[NSFileManager defaultManager] fileExistsAtPath: __path]) [[NSFileManager defaultManager] createDirectoryAtPath: __path withIntermediateDirectories: NO attributes: nil error: nil]
#define DELETE_FILE(__path) if ([[NSFileManager defaultManager] fileExistsAtPath: __path]) [[NSFileManager defaultManager] removeItemAtPath: __path error: nil]

//=================================================================================

@implementation MAController

//---------------------------------------------------------------------------------
+ (MAController*)sharedInstance
{
    static MAController* _s_inst = nil;
    if (!_s_inst) _s_inst = [[MAController alloc] init];
    return _s_inst;
}

//---------------------------------------------------------------------------------
- (id)init
{
    if (self = [super init])
    {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (![paths count])
        {
            _folder = [[NSString alloc] init];
        } else {
            _folder = [[paths objectAtIndex: 0] retain];
        }
        CREATE_FOLDER(_folder);
        
        _lists     = [[NSMutableArray alloc] init];
        _listSongs = [[NSMutableArray alloc] init];
        _aids      = [[NSMutableDictionary alloc] init];
        _songs     = [[NSMutableArray alloc] init];
        _o = [[NSNumber alloc] initWithInt: 1];
        _useL = SETT_BOOL_VAL(SETT_USE_LISTS);
        
        _item2 = [[MAVK alloc] initWithType: VKSearch];
        _item3 = [[MAVK alloc] initWithType: VKUrls];
        
        [self loadLists];
        [self loadSongs];
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(movieStateNotification:) name: MPMoviePlayerPlaybackStateDidChangeNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(movieFinishNotification:) name: MPMoviePlayerPlaybackDidFinishNotification object: nil];
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [_vc release];
    
    [_folder release];
    
    [_lists release];
    [_songs release];
    [_listSongs release];
    [_aids release];
    
    [_item2 release];
    [_item3 release];
    [_playTimer release];
    
    [_o release];
    
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (NSArray*)lists
{
    return _lists;
}

//---------------------------------------------------------------------------------
- (void)addList: (NSString*)name
{
    if (![name length]) name = LSTR(@"Add_Name");
    int m = 0;
    for (NSDictionary* list in _lists)
    {
        int i = [[list objectForKey: LIST_ID] intValue];
        if (i > m) m = i;
    }
    
    NSNumber* n = [[NSNumber alloc] initWithInt: m + 1];
    NSDictionary* d = [[NSDictionary alloc] initWithObjectsAndKeys: name, LIST_NAME, n, LIST_ID, nil];
    [n release];
    
    [_lists addObject: d];
    [d release];
    
    [self saveLists];
    [self setList: m + 1];
}

//---------------------------------------------------------------------------------
- (void)editList: (NSString*)name
{
    if (!_list || ![name length]) return;
    
    NSUInteger n = [_lists indexOfObject: _list];
    if (n == NSNotFound) return;
    
    NSMutableDictionary* d = [[NSMutableDictionary alloc] initWithDictionary: _list];
    NSString* s = [[NSString alloc] initWithString: name];
    [d setObject: s forKey: LIST_NAME];
    [s release];
    
    [_lists replaceObjectAtIndex: n withObject: d];
    [d release];
    [self saveLists];
    
    _list = d;
    [_vc reloadData];
}

//---------------------------------------------------------------------------------
- (void)deleteList: (NSInteger)n
{
    for (NSDictionary* list in _lists)
    {
        if ([[list objectForKey: LIST_ID] intValue] == n)
        {
            BOOL ch = (n == [[_list objectForKey: LIST_ID] intValue]);
            [_lists removeObject: list];
            [self saveLists];
            if (ch)
            {
                _list = nil;
                [self setList: 0];
            }
            break;
        }
    }
}

//---------------------------------------------------------------------------------
- (void)loadLists
{
    NSString* path = [[NSString alloc] initWithFormat: @"%@/%@", _folder, FILE_LISTS];
    if ([[NSFileManager defaultManager] fileExistsAtPath: path])
    {
        NSArray* arr = [[NSArray alloc] initWithContentsOfFile: path];
        if ([arr count])
        {
            [_lists removeAllObjects];
            [_lists addObjectsFromArray: arr];
        }
        [arr release];
    }
    [path release];
    
    [self setList: [[NSUserDefaults standardUserDefaults] integerForKey: SETT_LIST]];
}

//---------------------------------------------------------------------------------
- (void)saveLists
{
    NSString* path = [[NSString alloc] initWithFormat: @"%@/%@", _folder, FILE_LISTS];
    [_lists writeToFile: path atomically: YES];
    [path release];
}

//---------------------------------------------------------------------------------
- (void)loadListSongs
{
    if (!_list) return;
    
    [_listSongs removeAllObjects];
    
    NSString* path = [[NSString alloc] initWithFormat: FILE_LIST_FMT, _folder, [[_list objectForKey: LIST_ID] intValue]];
    if ([[NSFileManager defaultManager] fileExistsAtPath: path])
    {
        NSArray* items = [[NSArray alloc] initWithContentsOfFile: path];
        if ([items count]) [_listSongs addObjectsFromArray: items];
        [items release];
    }
    [path release];
    [_aids removeAllObjects];
    for (NSDictionary* item in _listSongs) [_aids setObject: _o forKey: [item objectForKey: SONG_AID]];
}

//---------------------------------------------------------------------------------
- (NSDictionary*)list
{
    return _list;
}

//---------------------------------------------------------------------------------
- (void)setList: (NSInteger)n
{
    int i = 0;
    for (NSDictionary* list in _lists)
    {
        if ([[list objectForKey: LIST_ID] intValue] == n)
        {
            _list = list;
            [[NSUserDefaults standardUserDefaults] setInteger: n forKey: SETT_LIST];
            if (i > 0)
            {
                [_list retain];
                [_lists removeObjectAtIndex: i];
                [_lists insertObject: _list atIndex: 0];
                [_list release];
                [self saveLists];
            }
            [self loadListSongs];
            [_vc reloadData];
            return;
        }
        i++;
    }
    if (_list) return;
    
    if (![_lists count])
    {
        NSNumber* n = [[NSNumber alloc] initWithInt: 1];
        NSDictionary* d = [[NSDictionary alloc] initWithObjectsAndKeys: LSTR(@"Add_Name"), LIST_NAME, n, LIST_ID, nil];
        [n release];
        
        [_lists addObject: d];
        [d release];
        
        [self saveLists];
        
        _list = d;
        [[NSUserDefaults standardUserDefaults] setInteger: 1 forKey: SETT_LIST];
        [_listSongs removeAllObjects];
        return;
    }
    
    _list = [_lists firstObject];
    [[NSUserDefaults standardUserDefaults] setInteger: [[_list objectForKey: LIST_ID] intValue] forKey: SETT_LIST];
    [self loadListSongs];
    [_vc reloadData];
}

//---------------------------------------------------------------------------------
- (NSArray*)listSongs
{
    return _listSongs;
}

//---------------------------------------------------------------------------------
- (void)saveListSongs
{
    if (!_list) return;
    
    NSString* path = [[NSString alloc] initWithFormat: FILE_LIST_FMT, _folder, [[_list objectForKey: LIST_ID] intValue]];
    [_listSongs writeToFile: path atomically: YES];
    [path release];
}

//---------------------------------------------------------------------------------
- (void)onSong: (NSDictionary*)song
{
    [self onSong: song isAdd: ![_aids objectForKey: [song objectForKey: SONG_AID]]];
}

//---------------------------------------------------------------------------------
- (void)onSong: (NSDictionary*)song isAdd: (BOOL)isAdd
{
    NSNumber* aid = [song objectForKey: SONG_AID];
    
    if (isAdd)
    {
        [_listSongs addObject: song];
        [self saveListSongs];
        [_aids setObject: _o forKey: aid];
    } else {
        [_aids removeObjectForKey: aid];
        for (NSDictionary* item in _listSongs)
        {
            if ([[item objectForKey: SONG_AID] isEqualToNumber: aid])
            {
                [_listSongs removeObject: item];
                [self saveListSongs];
                break;
            }
        }
    }
    
    NSUInteger n = [_lists indexOfObject: _list];
    if (n == NSNotFound) return;
    
    NSMutableDictionary* d = [[NSMutableDictionary alloc] initWithDictionary: _list];
    NSNumber* n1 = [[NSNumber alloc] initWithInt: [_listSongs count]];
    [d setObject: n1 forKey: LIST_TRACKS];
    [n1 release];
    
    [_lists replaceObjectAtIndex: n withObject: d];
    [d release];
    [self saveLists];
    
    _list = d;
}

//---------------------------------------------------------------------------------
- (NSDictionary*)aids
{
    return _aids;
}

//---------------------------------------------------------------------------------
- (void)loadInWindow: (UIWindow*)window
{
    _vc = [[MAViewController alloc] initWithNibName: nil bundle: nil];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController: _vc];
    [_vc release];
    nav.view.backgroundColor = [UIColor whiteColor];
    window.rootViewController = nav;
    [nav release];
    
    [_item3 act: nil];
    
    [NSTimer scheduledTimerWithTimeInterval: 2 target: self selector: @selector(rsTimer) userInfo: nil repeats: YES];
}

//---------------------------------------------------------------------------------
// songs
//---------------------------------------------------------------------------------
- (NSArray*)songs
{
    return _songs;
}

//---------------------------------------------------------------------------------
- (void)loadSongs
{
    NSString* path = [[NSString alloc] initWithFormat: FILE_SONGS, _folder];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: path])
    {
        NSArray* arr = [[NSArray alloc] initWithContentsOfFile: path];
        [_songs addObjectsFromArray: arr];
        [arr release];
    }
    [path release];
}

//---------------------------------------------------------------------------------
- (void)songsSave
{
    NSString* path = [[NSString alloc] initWithFormat: FILE_SONGS, _folder];
    [_songs writeToFile: path atomically: YES];
    [path release];
}

//---------------------------------------------------------------------------------
- (BOOL)playErr
{
    return _playErr;
}

//---------------------------------------------------------------------------------
- (void)playSong: (NSDictionary*)song isList: (BOOL)isList
{
    [NSObject cancelPreviousPerformRequestsWithTarget: self];
    _playErr = NO;
    if (![song objectForKey: SONG_URL]) song = nil;
    BOOL listCh = (isList != _playList);
    _playList = isList;
    
    if (_playTimer)
    {
        [_playTimer invalidate];
        [_playTimer release];
        _playTimer = nil;
    }
    
    if (song == _playSong && !listCh)
    {
        if (_playSong)
        {
            _playTimer = [[NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(playReloadState) userInfo: nil repeats: YES] retain];
            [self playReloadData];
        }
        return;
    }
    
    [song retain];
    [_playSong release];
    _playSong = song;
    
    if (!song)
    {
        _playStop = YES;
        [_player stop];
        [self playReloadData];
        [_vc reloadData];
        _playStop = NO;
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
        return;
    }
    _playStop = NO;
    
    NSURL* url = [[NSURL alloc] initWithString: [_playSong objectForKey: SONG_URL]];
    if (![url scheme])
    {
        _playStop = YES;
        [_player stop];
        [url release];
        [self playReloadData];
        [_vc reloadData];
        _playStop = NO;
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
        return;
    }
    
    NSDictionary* trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys: [_playSong objectForKey: SONG_TITLE], MPMediaItemPropertyTitle,
                               [_playSong objectForKey: SONG_ARTIST], MPMediaItemPropertyArtist,
                               [_playSong objectForKey: SONG_DUR], MPMediaItemPropertyPlaybackDuration,
                               nil];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = trackInfo;
    [trackInfo release];
    
    _playStop = YES;
    
    [_player stop];
    [_player release];
    _player = nil;
    
    _playStop = NO;
    
    if (!_player)
    {
        _player = [[MPMoviePlayerController alloc] initWithContentURL: url];
        _player.controlStyle = MPMovieControlStyleNone;
    } else {
        _player.contentURL = url;
        _player.currentPlaybackTime = 0;
    }
    [url release];
    
    _playTimer = [[NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(playReloadState) userInfo: nil repeats: YES] retain];
    
    [_player prepareToPlay];
    [_player play];
    
    [self playReloadData];
    
    [_vc reloadData];
}

//---------------------------------------------------------------------------------
- (void)playReloadState
{
    if (_playStop) return;
    BOOL isStop = [[MAPlayerView sharedInstance] reloadState];
    
    MAProgressView* pr = (_playList) ? [[MASongRCellCur sharedInstance] progress] : [[MASongCellCur sharedInstance] progress];
    [pr setProgress: _player.currentPlaybackTime];
    [pr setIsStop: isStop];
}

//---------------------------------------------------------------------------------
- (void)playReloadData
{
    if (_playStop) return;
    int d = [[MAPlayerView sharedInstance] reloadData];
    BOOL isStop = [[MAPlayerView sharedInstance] reloadState];
    
    MAProgressView* pr = (_playList) ? [[MASongRCellCur sharedInstance] progress] : [[MASongCellCur sharedInstance] progress];
    [pr setMaximumValue: d];
    [pr setProgress: _player.currentPlaybackTime];
    [pr setIsStop: isStop];
}

//---------------------------------------------------------------------------------
- (NSDictionary*)song
{
    return (_playList) ? nil : _playSong;
}

//---------------------------------------------------------------------------------
- (NSDictionary*)listSong
{
    return (_playList) ? _playSong : nil;
}

//---------------------------------------------------------------------------------
- (MPMoviePlayerController*)player
{
    return _player;
}

//---------------------------------------------------------------------------------
- (void)onPlay
{
    NSDictionary* song = (_playList) ? [self listSong] : [self song];
    
    if (!song)
    {
        _playList = [_vc isList];
        [self nextTrack];
        return;
    }
    
    if (!_player) return;
    if (_playErr)
    {
        [self playSong: nil isList: NO];
        return;
    }
    
    if (_player.playbackState == MPMoviePlaybackStatePlaying || _player.playbackState == MPMoviePlaybackStateSeekingForward || _player.playbackState == MPMoviePlaybackStateSeekingBackward)
    {
        [_player pause];
    } else {
        [_player play];
    }
    [self playReloadState];
}

//---------------------------------------------------------------------------------
- (void)onPlayRem
{
    if (!_player) return;
    [_player play];
    [self playReloadState];
}

//---------------------------------------------------------------------------------
- (void)onPauseRem
{
    if (!_player) return;
    [_player pause];
    [self playReloadState];
}

//---------------------------------------------------------------------------------
- (void)previousTrack
{
    //_playList = YES;
    
    NSDictionary* song = [self previousSong: _playList];
    if (!song) return;
    
    [_playSong release];
    _playSong = nil;
    [self playSong: song isList: _playList];
}

//---------------------------------------------------------------------------------
- (void)nextTrack
{
    //_playList = YES;
    NSDictionary* song = [self nextSong: _playList];
    
    [_playSong release];
    _playSong = nil;
    [self playSong: song isList: _playList];
}

//---------------------------------------------------------------------------------
- (NSDictionary*)previousSong: (BOOL)isList
{
    NSArray* items = (isList) ? _listSongs : _songs;
    if (![items count]) return nil;
    NSDictionary* song = (isList) ? [self listSong] : [self song];
    if (!song) return [items lastObject];
    
    NSNumber* aid = [song objectForKey: SONG_AID];
    int i = -1;
    for (int j = 0; j < [items count]; j++)
    {
        if ([[[items objectAtIndex: j] objectForKey: SONG_AID] isEqualToNumber: aid])
        {
            i = j;
            break;
        }
    }
    if (i < 0 || i == 0) return [items lastObject];
    return [items objectAtIndex: i - 1];
}

//---------------------------------------------------------------------------------
- (NSDictionary*)nextSong: (BOOL)isList
{
    NSArray* items = (isList) ? _listSongs : _songs;
    if (![items count]) return nil;
    NSDictionary* song = (isList) ? [self listSong] : [self song];
    if (!song) return [items firstObject];
    
    NSNumber* aid = [song objectForKey: SONG_AID];
    int i = -1;
    for (int j = 0; j < [items count]; j++)
    {
        if ([[[items objectAtIndex: j] objectForKey: SONG_AID] isEqualToNumber: aid])
        {
            i = j;
            break;
        }
    }
    if (i < 0 || i == [items count] - 1) return [items firstObject];
    return [items objectAtIndex: i + 1];
}

//---------------------------------------------------------------------------------
- (void)stepTrack: (float)t
{
    MPMoviePlayerController* p = [self player];
    if (!p) return;
    
    p.currentPlaybackTime = t;
    //[[MAProgressView sharedInstance] setProgress: t];
}

//---------------------------------------------------------------------------------
// MPMoviePlayerPlaybackStateDidChangeNotification
//---------------------------------------------------------------------------------
- (void)movieStateNotification: (NSNotification*)notification
{
    if ([notification object] == _player) [self playReloadState];
}

//---------------------------------------------------------------------------------
// MPMoviePlayerPlaybackDidFinishNotification
//---------------------------------------------------------------------------------
- (void)movieFinishNotification: (NSNotification*)notification
{
    if (_playStop)
    {
        _playStop = NO;
        return;
    }
    
    MPMovieFinishReason r = [[notification.userInfo objectForKey: MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (r == MPMovieFinishReasonPlaybackError)
    {
        _playErr = YES;
        [self playReloadState];
        if (SETT_BOOL_VAL(SETT_SQ)) [self performSelector: @selector(nextTrack) withObject: nil afterDelay: 3];
        return;
    }
    if (SETT_BOOL_VAL(SETT_SQ))
    {
        NSDictionary* song = [self nextSong: _playList];
        [_playSong release];
        _playSong = nil;
        [self playSong: song isList: _playList];
    } else {
        [_playSong release];
        _playSong = nil;
    }
}

//---------------------------------------------------------------------------------
- (void)shuffleSongs
{
    static BOOL _s_seeded = NO;
    if (!_s_seeded)
    {
        _s_seeded = YES;
        srandom((int)time(NULL));
    }
    
    NSUInteger count = [_listSongs count];
    for (NSUInteger i = 0; i < count; ++i)
    {
        NSUInteger nElements = count - i;
        NSUInteger n = (random() % nElements) + i;
        if (i != n) [_listSongs exchangeObjectAtIndex: i withObjectAtIndex: n];
    }
    [self saveListSongs];
    [_vc reloadData];
}

//---------------------------------------------------------------------------------
- (void)rsTimer
{
    if ([NSDate timeIntervalSinceReferenceDate] - _urlsTime > URLS_OLD_TIME) [_item3 act: nil];
}

//---------------------------------------------------------------------------------
- (void)onSett
{
    UIViewController* vc = [[MASettController alloc] initWithStyle: UITableViewStyleGrouped];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController: vc];
    [vc release];
    [_vc presentViewController: nav animated: YES completion: nil];
    [nav release];
}

//---------------------------------------------------------------------------------
- (void)onSettUseL
{
    _useL = SETT_BOOL_VAL(SETT_USE_LISTS);
    [_vc reloadData];
}

//---------------------------------------------------------------------------------
- (BOOL)useL
{
    return _useL;
}

//---------------------------------------------------------------------------------
- (void)onLists
{
    UIViewController* vc = [[MAListsController alloc] initWithStyle: UITableViewStyleGrouped];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController: vc];
    [vc release];
    [_vc presentViewController: nav animated: YES completion: nil];
    [nav release];
}

//---------------------------------------------------------------------------------
// update urls for songs
//---------------------------------------------------------------------------------
- (void)songsUrls: (NSArray*)items
{
    _urlsTime = [NSDate timeIntervalSinceReferenceDate];
    NSMutableDictionary* d = [[NSMutableDictionary alloc] init];
    for (NSMutableDictionary* item in items)
    {
        [d setObject: item forKey: [item objectForKey: SONG_AID]];
    }
    
    for (int i = 0; i < [_listSongs count]; i++)
    {
        NSDictionary* item = [_listSongs objectAtIndex: i];
        NSMutableDictionary* item2 = [d objectForKey: [item objectForKey: SONG_AID]];
        if (item2)
        {
            [item2 setObject: [item objectForKey: SONG_DUR_STR]  forKey: SONG_DUR_STR];
            [_listSongs replaceObjectAtIndex: i withObject: item2];
        }
    }
    
    for (int i = 0; i < [_songs count]; i++)
    {
        NSDictionary* item = [_songs objectAtIndex: i];
        NSMutableDictionary* item2 = [d objectForKey: [item objectForKey: SONG_AID]];
        if (item2)
        {
            [item2 setObject: [item objectForKey: SONG_DUR_STR]  forKey: SONG_DUR_STR];
            [_songs replaceObjectAtIndex: i withObject: item2];
        }
    }
    
    [d release];
    
    [self saveListSongs];
}

//---------------------------------------------------------------------------------
// static
//---------------------------------------------------------------------------------
+ (UIColor*)btTextColor
{
    static UIColor* _s_color = nil;
    if (!_s_color) _s_color = [[UIColor colorWithRed: 0.2 green: 0.4 blue: 0.6 alpha: 1] retain];
    return _s_color;
}

//---------------------------------------------------------------------------------
+ (int)osVer
{
    static int _s_osVer = 0;
    if (!_s_osVer)
    {
        NSString* v = [[UIDevice currentDevice] systemVersion];
        unichar c = ([v length]) ? [v characterAtIndex: 0] : 0;
        if (c > '0') _s_osVer = c - '0';
    }
    return _s_osVer;
}

@end
