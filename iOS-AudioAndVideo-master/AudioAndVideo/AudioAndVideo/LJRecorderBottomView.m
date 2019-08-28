//
//  LJRecorderBottomView.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/3/21.
//  Copyright © 2017年 LiJie. All rights reserved.
//


typedef NS_ENUM(NSInteger,ButtonStyle) {
    ButtonStyleRecord = 3,
    ButtonStyleLocation = 4,
};

#import "LJRecorderBottomView.h"

@interface LJRecorderBottomView()
@property(nonatomic,strong)UIButton *locationVideoButton;
@property(nonatomic,strong)UIButton *recordVideoButton;
@end

@implementation LJRecorderBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    _recordVideoButton = [self setButtonWithNormalImage:@"videoRecord" selectedImage:@"videoPause" buttonStyle:ButtonStyleRecord];
    
    _locationVideoButton = [self setButtonWithNormalImage:@"locationVideo" selectedImage:@"locationVideo" buttonStyle:ButtonStyleLocation];
    
    _recordVideoButton.centerY = self.height / 2;
    _recordVideoButton.centerX = self.width / 2;
    
    _locationVideoButton.right = self.right - kScale(20);
    _locationVideoButton.centerY = self.height / 2;

}

- (UIButton *)setButtonWithNormalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage buttonStyle:(ButtonStyle)buttonStyle {
    
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [button  setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    button.tag = buttonStyle;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [self addSubview:button];
    return button;
}

- (void)buttonClick:(UIButton *)button {
    if (button.tag == ButtonStyleLocation) {
        if ([self.delegate respondsToSelector:@selector(locationButtonClick:)]) {
            [self.delegate locationButtonClick:button];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(videoRecorderButtonClick:)]) {
            [self.delegate videoRecorderButtonClick:button];
        }
        button.selected = !button.selected;
    }
}

- (void)hiddenLocationButton:(BOOL)hidden {
    
    if (hidden) {
        self.locationVideoButton.hidden = YES;
    }else {
        self.locationVideoButton.hidden = NO;
    }
    
}

@end
