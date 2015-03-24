//
//  MASongCell.m
//
//  Created by M on 02.05.14.
//  Copyright (c) 2014. All rights reserved.
//

#import "MASongCell.h"
#import "MAConstants.h"
#import "MAController.h"
#import "MAProgressView.h"

#define SONG_IMG_SZ 32
#define SONG_X 10
// title
#define SONG_TITLE_Y 5
#define SONG_TITLE_H 20
#define SONG_TITLE_FONT 16
// art
#define SONG_ART_Y 25
#define SONG_ART_H 20
#define SONG_ART_FONT 13
#define SONG_ART_DX 30
// dur
#define SONG_DUR_W 50

//=================================================================================

@implementation MASongCell

//---------------------------------------------------------------------------------
+ (NSString *)identifier
{
    static NSString* _s_identifier = @"MASongCell";
    return _s_identifier;
}

//---------------------------------------------------------------------------------
+ (UIImage *)imgAdded
{
    static UIImage* _s_img = nil;
    if (!_s_img) _s_img = [[UIImage imageNamed: @"added"] retain];
    return _s_img;
}

//---------------------------------------------------------------------------------
+ (UIImage *)imgAdd
{
    static UIImage* _s_img = nil;
    if (!_s_img) _s_img = [[UIImage imageNamed: @"add"] retain];
    return _s_img;
}

//---------------------------------------------------------------------------------
+ (UIImage *)imgPlay
{
    static UIImage* _s_img = nil;
    if (!_s_img) _s_img = [[UIImage imageNamed: @"play"] retain];
    return _s_img;
}

//---------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle: style reuseIdentifier: reuseIdentifier])
    {
        float w = self.bounds.size.width;
        
        float x = SONG_X + SONG_IMG_SZ + SONG_X;
        ADD_LABEL(_title, x, SONG_TITLE_Y, w - x - SONG_IMG_SZ - SONG_X, SONG_TITLE_H, SZ(Width), SONG_TITLE_FONT, YES, self.contentView);
        ADD_LABEL(_art, x, SONG_ART_Y, w - x - SONG_IMG_SZ - SONG_X - SONG_ART_DX, SONG_ART_H, SZ(Width), SONG_ART_FONT, NO, self.contentView);
        ADD_LABEL(_dur, w - SONG_DUR_W - SONG_IMG_SZ - SONG_X, SONG_ART_Y, SONG_DUR_W, SONG_ART_H, SZ_M(Left), SONG_ART_FONT, NO, self.contentView);
        _dur.textAlignment = UITextAlignmentRight;
        _dur.textColor = [UIColor grayColor];
        
        _img = [[UIImageView alloc] initWithImage: [MASongCell imgAdd]];
        _img.frame = CGRectMake(SONG_X, (SONG_ROW_H - SONG_IMG_SZ) / 2, SONG_IMG_SZ, SONG_IMG_SZ);
        [self addSubview: _img];
        [_img release];
        
        UIImageView* v = [[UIImageView alloc] initWithImage: [MASongCell imgPlay]];
        v.autoresizingMask = SZ_M(Left);
        v.frame = CGRectMake(w - SONG_IMG_SZ - SONG_X, (SONG_ROW_H - SONG_IMG_SZ) / 2, SONG_IMG_SZ, SONG_IMG_SZ);
        [self addSubview: v];
        [v release];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)setItem: (NSDictionary*)item isChk: (BOOL)isChk
{
    BOOL useL = [MA_CONTROLLER useL];
    
    if (useL)
    {
        if (!_img)
        {
            float w = self.bounds.size.width;
            _img = [[UIImageView alloc] initWithImage: [MASongCell imgAdd]];
            _img.frame = CGRectMake(SONG_X, (SONG_ROW_H - SONG_IMG_SZ) / 2, SONG_IMG_SZ, SONG_IMG_SZ);
            [self addSubview: _img];
            [_img release];
            
            float x = SONG_X + SONG_IMG_SZ + SONG_X;
            _title.frame = CGRectMake(x, SONG_TITLE_Y, w - x - SONG_IMG_SZ - SONG_X, SONG_TITLE_H);
            _art.frame = CGRectMake(x, SONG_ART_Y, w - x - SONG_IMG_SZ - SONG_X - SONG_ART_DX, SONG_ART_H);
        }
        [_img setImage: (isChk) ? [MASongCell imgAdded] : [MASongCell imgAdd]];
    } else {
        if (_img)
        {
            [_img removeFromSuperview];
            _img = nil;
            float w = self.bounds.size.width;
            float x = SONG_X;
            _title.frame = CGRectMake(x, SONG_TITLE_Y, w - x - SONG_IMG_SZ - SONG_X, SONG_TITLE_H);
            _art.frame = CGRectMake(x, SONG_ART_Y, w - x - SONG_IMG_SZ - SONG_X - SONG_ART_DX, SONG_ART_H);
        }
    }
    
    _title.text = [item objectForKey: SONG_TITLE];
    _art.text = [item objectForKey: SONG_ARTIST];
    _dur.text = [item objectForKey: SONG_DUR_STR];
}

//---------------------------------------------------------------------------------
- (void)setText: (NSString*)text
{
    _title.text = text;
    _art.text = @"";
    _dur.text = @"";
}

//---------------------------------------------------------------------------------
- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

@end

//=================================================================================

@interface MASongCellCur ()
{
    MAProgressView* _pr;
}
@end

//=================================================================================

@implementation MASongCellCur

+ (MASongCellCur*)sharedInstance
{
    static MASongCellCur* _s_inst = nil;
    if (!_s_inst) _s_inst = [[MASongCellCur alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: nil];
    return _s_inst;
}

//---------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle: style reuseIdentifier: reuseIdentifier])
    {
        CGRect r = self.bounds;
        self.contentView.backgroundColor = [UIColor colorWithRed: 0.9 green: 0.95 blue: 1 alpha: 1];
        
        _pr = [[MAProgressView alloc] initWithFrame: CGRectMake(r.size.width - PROGRESS_SZ - 5, (SONG_ROW_H - PROGRESS_SZ) / 2, PROGRESS_SZ, PROGRESS_SZ)];
        _pr.autoresizingMask = SZ_M(Left);
        [self addSubview: _pr];
        [_pr release];
        [_pr addTarget: MA_CONTROLLER action: @selector(onPlay) forControlEvents: UIControlEventTouchDown];
    }
    return self;
}

//---------------------------------------------------------------------------------
- (MAProgressView*)progress
{
    return _pr;
}

@end

//=================================================================================

@implementation MASongRCell

//---------------------------------------------------------------------------------
+ (NSString *)identifier
{
    static NSString *identifier = @"MASongRCell";
    return identifier;
}

//---------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle: style reuseIdentifier: reuseIdentifier])
    {
        float w = self.bounds.size.width;
        float x = SONG_X;
        ADD_LABEL(_title, x, SONG_TITLE_Y, w - x - SONG_X, SONG_TITLE_H, SZ(Width), SONG_TITLE_FONT, YES, self.contentView);
        ADD_LABEL(_art, x, SONG_ART_Y, w - x - SONG_X - SONG_ART_DX, SONG_ART_H, SZ(Width), SONG_ART_FONT, NO, self.contentView);
        ADD_LABEL(_dur, w - SONG_DUR_W - SONG_X, SONG_ART_Y, SONG_DUR_W, SONG_ART_H, SZ_M(Left), SONG_ART_FONT, NO, self.contentView);
        _dur.textColor = [UIColor grayColor];
        _dur.textAlignment = UITextAlignmentRight;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)setItem: (NSDictionary*)item
{
    _title.text = [item objectForKey: SONG_TITLE];
    _art.text   = [item objectForKey: SONG_ARTIST];
    _dur.text   = [item objectForKey: SONG_DUR_STR];
}

//---------------------------------------------------------------------------------
- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

@end

//=================================================================================

@interface MASongRCellCur ()
{
    MAProgressView* _pr;
}
@end

//=================================================================================

@implementation MASongRCellCur

//---------------------------------------------------------------------------------
+ (MASongRCellCur*)sharedInstance
{
    static MASongRCellCur* _s_inst = nil;
    if (!_s_inst) _s_inst = [[MASongRCellCur alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: nil];
    return _s_inst;
}

//---------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle: style reuseIdentifier: reuseIdentifier])
    {
        float w = self.bounds.size.width;
        self.contentView.backgroundColor = [UIColor colorWithRed: 0.9 green: 0.95 blue: 1 alpha: 1];
        
        float x = SONG_X;
        _title.frame = CGRectMake(x, SONG_TITLE_Y, w - x - SONG_IMG_SZ - SONG_X, SONG_TITLE_H);
        _art.frame = CGRectMake(x, SONG_ART_Y, w - x - SONG_IMG_SZ - SONG_X - SONG_ART_DX, SONG_ART_H);
        _dur.frame = CGRectMake(w - SONG_DUR_W - SONG_IMG_SZ - SONG_X, SONG_ART_Y, SONG_DUR_W, SONG_ART_H);
        
        _pr = [[MAProgressView alloc] initWithFrame: CGRectMake(w - PROGRESS_SZ - 5, (self.bounds.size.height - PROGRESS_SZ) / 2, PROGRESS_SZ, PROGRESS_SZ)];
        _pr.autoresizingMask = SZ_M(Top) | SZ_M(Bottom) | SZ_M(Left);
        [self addSubview: _pr];
        [_pr release];
        [_pr addTarget: MA_CONTROLLER action: @selector(onPlay) forControlEvents: UIControlEventTouchDown];
    }
    return self;
}

//---------------------------------------------------------------------------------
- (MAProgressView*)progress
{
    return _pr;
}

@end

