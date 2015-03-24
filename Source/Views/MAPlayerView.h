//
//  MAPlayerView.h
//  MAMusicVK
//
//  Created by M on 02.03.15.
//  Copyright (c) 2015. All rights reserved.
//

#define PLAY_PANEL_H 120
#define PLAY_BT_SZ 32

@interface MAPlayerView : UIView

+ (MAPlayerView*)sharedInstance;

// return dur
- (int)reloadData;

// return isStop
- (BOOL)reloadState;

- (void)setIsFreeze: (BOOL)isFreeze;
- (BOOL)isFreeze;

- (float)progress;
- (float)dur;

@end
