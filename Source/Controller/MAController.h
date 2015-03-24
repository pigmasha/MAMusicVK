//
//  MAController.h
//
//  Created by M on 01.05.14.
//  Copyright (c) 2014. All rights reserved.
//

// lists
#define LIST_ID      @"i"
#define LIST_NAME    @"n"
#define LIST_TRACKS  @"t"

// songs
#define SONG_TITLE   @"t"
#define SONG_ARTIST  @"a"
#define SONG_AID     @"i"
#define SONG_DUR     @"d"
#define SONG_DUR_STR @"ds"
#define SONG_URL     @"u"
#define SONG_OWNER   @"o"

@class MPMoviePlayerController;

#define MA_CONTROLLER [MAController sharedInstance]

@interface MAController : NSObject

+ (MAController*)sharedInstance;

- (void)loadInWindow: (UIWindow*)window;

- (NSArray*)lists;
- (void)addList: (NSString*)name;
- (void)editList: (NSString*)name;
- (void)deleteList: (NSInteger)n;

- (NSDictionary*)list;
- (void)setList: (NSInteger)n;

- (NSArray*)listSongs;
- (void)onSong: (NSDictionary*)song; // on / off song
- (void)onSong: (NSDictionary*)song isAdd: (BOOL)isAdd;
- (NSDictionary*)aids;

// songs
- (NSArray*)songs;

- (void)playSong: (NSDictionary*)song isList: (BOOL)isList;
- (BOOL)playErr;
- (NSDictionary*)song;
- (NSDictionary*)listSong;

- (MPMoviePlayerController*)player;
- (void)onPlay;
- (void)onPlayRem;
- (void)onPauseRem;
- (void)previousTrack;
- (void)nextTrack;
- (void)stepTrack: (float)t;

- (void)shuffleSongs;

- (void)songsUrls: (NSArray*)items; // update urls for songs

- (void)onSett;
- (void)onSettUseL;

- (BOOL)useL;

- (void)onLists;

// static
+ (UIColor*)btTextColor;
+ (int)osVer;

@end
