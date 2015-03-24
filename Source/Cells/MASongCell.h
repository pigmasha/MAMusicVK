//
//  MASongCell.h
//
//  Created by M on 02.05.14.
//  Copyright (c) 2014. All rights reserved.
//

#define SONG_ROW_H 52

@class MAProgressView;

@interface MASongCell : UITableViewCell
{
    UILabel* _title;
    UILabel* _art;
    UIImageView* _img;
    UILabel* _dur;
}

+ (NSString*)identifier;

- (void)setItem: (NSDictionary*)item isChk: (BOOL)isChk;
- (void)setText: (NSString*)text;

@end

//=================================================================================

@interface MASongCellCur : MASongCell

+ (MASongCellCur*)sharedInstance;

- (MAProgressView*)progress;

@end

//=================================================================================

@interface MASongRCell : UITableViewCell
{
    UILabel* _title;
    UILabel* _art;
    UILabel* _dur;
}

+ (NSString*)identifier;
- (void)setItem: (NSDictionary*)item;

@end

//=================================================================================

@interface MASongRCellCur : MASongRCell

+ (MASongRCellCur*)sharedInstance;

- (MAProgressView*)progress;

@end
