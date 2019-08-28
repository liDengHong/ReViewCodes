//
//  LJRecorderTopView.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/3/21.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJRecorderTopView.h"

typedef NS_ENUM(NSInteger,ButtonType) {
    
    ButtonTypeBack = 0,
    ButtonTypeChangeCanmera = 1,
    ButtonTypeFlash = 2,
    ButtonTypeNextPage = 3,
};

@interface LJRecorderTopView()

@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)UIButton *changeCameraButton;
@property(nonatomic,strong)UIButton *flashButton;
@property(nonatomic,strong)UIButton *nextPageButton;

@end

@implementation LJRecorderTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    return self;
}

- (void)setupUI {
    _backButton = [self setButtonWithNormalImage:@"closeVideo" selectedImage:@"closeVideo" buttonType:ButtonTypeBack];
    _changeCameraButton = [self setButtonWithNormalImage:@"changeCamera" selectedImage:@"changeCamera" buttonType:ButtonTypeChangeCanmera];
    _flashButton = [self setButtonWithNormalImage:@"flashlightOff" selectedImage:@"flashlightOn" buttonType:ButtonTypeFlash];
    _nextPageButton = [self setButtonWithNormalImage:@"videoNext" selectedImage:@"videoNext" buttonType:ButtonTypeNextPage];
    
    _backButton.left = self.left + kScale(20);
    _backButton.centerY = self.height / 2;
    
    _nextPageButton.right = self.right - kScale(20);
    _nextPageButton.centerY = self.height / 2;
    
    _flashButton.centerY = self.height / 2;
    _flashButton.right = self.width / 2 - kScale(30);
    
    _changeCameraButton.centerY = self.height / 2;
    _changeCameraButton.left = self.width / 2 + kScale(30);
    
}

- (UIButton *)setButtonWithNormalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage buttonType:(ButtonType)buttonType  {

    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [button  setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    button.tag = buttonType;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [button sizeToFit];
    return button;
}

- (void)buttonClick:(UIButton *)button {
    
    if (button.tag == ButtonTypeBack) {
        if ([self.delegate respondsToSelector:@selector(backButtonClick:)]) {
            [self.delegate backButtonClick:button];
        }
    } else if (button.tag == ButtonTypeFlash) {
        if ([self.delegate respondsToSelector:@selector(flashButtonClick:)]) {
            [self.delegate flashButtonClick:button];
        }
//        button.selected = !button.selected;
    } else if (button.tag == ButtonTypeNextPage) {
        if ([self.delegate respondsToSelector:@selector(nextPageButtonClick:)]) {
            [self.delegate nextPageButtonClick:button];
        }
    } else if (button.tag == ButtonTypeChangeCanmera) {
        if ([self.delegate respondsToSelector:@selector(changeCameraButtonClick:)]) {
            [self.delegate changeCameraButtonClick:button];
        }
    }
    
}

/**< 切换摄像头时闪关灯状态的变化 >**/
- (void)closeFlashStatusIsOpen:(BOOL)isOpen;
 {
     if (isOpen) {
         _flashButton.selected = NO;
     } else {
         return;
     }
}
@end
