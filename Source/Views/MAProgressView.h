
#define PROGRESS_SZ 36

@interface MAProgressView : UIControl

- (void)setMaximumValue: (float)val;
- (void)setProgress: (float)progress;

- (void)setIsStop: (BOOL)isStop;

@end
