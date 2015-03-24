//
//  MACells.m
//
//  Created by M on 17.11.14.
//  Copyright (c) 2014. All rights reserved.
//

#import "MACells.h"

@implementation MAZeroCell

//---------------------------------------------------------------------------------
- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

@end

//=================================================================================

@interface MAInputCell ()
{
    UITextField* _input;
}

@end

//=================================================================================

@implementation MAInputCell

//---------------------------------------------------------------------------------
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle: UITableViewCellStyleDefault reuseIdentifier: nil])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGSize sz = self.contentView.bounds.size;
        
        _input = [[UITextField alloc] initWithFrame: CGRectMake(15, 10, sz.width - 25, sz.height - 20)];
        _input.autoresizingMask = SZ(Width) | SZ(Height);
        [self.contentView addSubview: _input];
        [_input release];
    }
    return self;
}

//---------------------------------------------------------------------------------
- (UITextField*)input
{
    return _input;
}

@end


