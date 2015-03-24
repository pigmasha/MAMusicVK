#import "MAProgressView.h"

#define PROG_STEPS 50
#define PROG_TIME 0.03

//=================================================================================

@interface MAProgressView()
{
    float _max;
    float _progress;
    UIBezierPath* _pCirc;
    UIBezierPath* _pArc;
    UIBezierPath* _pButt;
    UIBezierPath* _pButt2;
    UIColor* _c;
    BOOL _isStop;
}
@end

//=================================================================================

@implementation MAProgressView

//---------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame: frame])
    {
        self.backgroundColor = [UIColor colorWithRed: 0.9 green: 0.95 blue: 1 alpha: 1];
        _pCirc = [[UIBezierPath bezierPathWithOvalInRect: CGRectMake(1, 1, PROGRESS_SZ - 2, PROGRESS_SZ - 2)] retain];
        _pButt = nil;
        _c = [[UIColor colorWithRed: 0 green: 0.478 blue: 1 alpha: 1] retain];
        _max = 1;
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_pCirc release];
    [_pArc  release];
    [_pButt  release];
    [_pButt2 release];
    [_c release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
{
    [_c set];
    
    [_pCirc stroke];
    [_pArc stroke];
    [_pButt fill];
    [_pButt2 fill];
}

//---------------------------------------------------------------------------------
- (void)setMaximumValue: (float)val
{
    if (val) _max = val;
}

//---------------------------------------------------------------------------------
- (void)setProgress: (float)progress
{
    if (_progress == progress) return;
    _progress = progress;
    
    float p = _progress / _max;
    
    [_pArc release];
    if (p)
    {
        _pArc = [[UIBezierPath bezierPathWithArcCenter: CGPointMake(PROGRESS_SZ / 2, PROGRESS_SZ / 2) radius: PROGRESS_SZ / 2 - 2.5
                                           startAngle: - M_PI_2 endAngle: -M_PI_2 + p * 2 * M_PI clockwise: YES] retain];
        _pArc.lineWidth = 3;
    } else {
        _pArc = nil;
    }
    [self setNeedsDisplay];
}

//---------------------------------------------------------------------------------
- (void)setIsStop: (BOOL)isStop
{
    if (_isStop == isStop) return;
    _isStop = isStop;
    
    [_pButt  release];
    [_pButt2 release];
    _pButt2 = nil;
    
    if (isStop)
    {
        _pButt = [[UIBezierPath alloc] init];
        [_pButt moveToPoint: CGPointMake(PROGRESS_SZ / 3 + 2, PROGRESS_SZ / 3 - 3)];
        [_pButt addLineToPoint: CGPointMake(PROGRESS_SZ / 3 + 2, 2 * PROGRESS_SZ / 3 + 3)];
        [_pButt addLineToPoint: CGPointMake(2 * PROGRESS_SZ / 3 + 4, PROGRESS_SZ / 2)];
        [_pButt closePath];
    } else {
        _pButt  = [[UIBezierPath bezierPathWithRect: CGRectMake(PROGRESS_SZ / 3, PROGRESS_SZ / 3, 0.35 * PROGRESS_SZ / 3, PROGRESS_SZ / 3)] retain];
        _pButt2 = [[UIBezierPath bezierPathWithRect: CGRectMake(1.65 * PROGRESS_SZ / 3, PROGRESS_SZ / 3, 0.35 * PROGRESS_SZ / 3, PROGRESS_SZ / 3)] retain];
    }
    [self setNeedsDisplay];
}

@end
