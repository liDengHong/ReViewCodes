//
//  ALPVCenterView.m
//

#import "AlilyunViewLoadingView.h"
#import "AliyunPlayerViewGifView.h"
#import <Foundation/NSBundle.h>
#import "AliyunPrivateDefine.h"

static const CGFloat AlilyunViewLoadingViewGifViewWidth   = 28;   //gifView 宽度
static const CGFloat AlilyunViewLoadingViewGifViewHeight  = 28;   //gifView 高度
static const CGFloat AlilyunViewLoadingViewMargin         = 2;    //间隙

@interface AlilyunViewLoadingView ()
@property (nonatomic, strong) AliyunPlayerViewGifView *gifView;
@property (nonatomic, strong) UILabel *tipLabelView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation AlilyunViewLoadingView

- (AliyunPlayerViewGifView *)gifView{
    if (!_gifView) {
        _gifView = [[AliyunPlayerViewGifView alloc] init];
        [_gifView setGifImageWithName:@"al_loader"];
    }
    return _gifView;
}

- (UILabel *)tipLabelView{
    if (!_tipLabelView) {
        NSBundle *resourceBundle = [AliyunUtil languageBundle];
        NSString *str = NSLocalizedStringFromTableInBundle(@"loading", nil, resourceBundle, nil);
        _tipLabelView = [[UILabel alloc] init];
        [_tipLabelView setText:str];
        [_tipLabelView setTextColor:kALYPVColorTextNomal];
        [_tipLabelView setFont:[UIFont systemFontOfSize:[AliyunUtil nomalTextSize]]];
        [_tipLabelView setTextAlignment:NSTextAlignmentCenter];
    }
    return _tipLabelView;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc]init];
    }
    return _indicatorView;
}

#pragma mark - init
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setHidden:YES];
//        [self addSubview:self.gifView];
        [self addSubview:self.tipLabelView];
        [self addSubview:self.indicatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    float width = self.bounds.size.width;
    float margin = AlilyunViewLoadingViewMargin;
    float textHeight = [AliyunUtil nomalTextSize];
    float messageViewY = (width - textHeight) / 2;
    self.tipLabelView.frame = CGRectMake(0, messageViewY, width, textHeight);
    float gifWidth = AlilyunViewLoadingViewGifViewWidth;
    float gifHeight = AlilyunViewLoadingViewGifViewHeight;
    self.indicatorView.frame = CGRectMake((width - gifWidth) / 2, messageViewY - gifHeight - margin, gifWidth, gifWidth);
    [self.indicatorView startAnimating];
}

#pragma mark - public method
- (void)show {
    if (![self isHidden]) {
        return;
    }
    [self.indicatorView startAnimating];
    [self setHidden:NO];
}

- (void)dismiss {
    if ([self isHidden]) {
        return;
    }
    [self.indicatorView stopAnimating];
    [self setHidden:YES];
}

@end
