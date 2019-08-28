//
//  LJRecorderTopView.h
//  AudioAndVideo
//
//  Created by LiJie on 2017/3/21.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LJRecorderTopViewDelegate <NSObject>

@required
- (void)backButtonClick:(UIButton *)button;
- (void)flashButtonClick:(UIButton *)button;
- (void)changeCameraButtonClick:(UIButton *)button;
- (void)nextPageButtonClick:(UIButton *)button;
@end

@interface LJRecorderTopView : UIView
@property(nonatomic,weak)id<LJRecorderTopViewDelegate>delegate;
- (void)closeFlashStatusIsOpen:(BOOL)isOpen;
@end
