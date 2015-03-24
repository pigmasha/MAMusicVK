//
//  MATableView.m
//
//  Created by M on 08.11.13.
//

#import "MATableView.h"
#import "MAConstants.h"

@implementation MATableView

//---------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame: frame style: style])
    {
        self.autoresizingMask = SZ(Width) | SZ(Height);
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView: self];
    _lastX = p.x;
    [super touchesEnded: touches withEvent: event];
}

//---------------------------------------------------------------------------------
- (CGFloat)lastX
{
    return _lastX;
}

@end
