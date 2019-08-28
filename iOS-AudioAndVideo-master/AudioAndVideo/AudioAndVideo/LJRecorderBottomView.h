//
//  LJRecorderBottomView.h
//  AudioAndVideo
//
//  Created by LiJie on 2017/3/21.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LJRecorderBottomViewDelegate <NSObject>

- (void)locationButtonClick:(UIButton *)button;
- (void)videoRecorderButtonClick:(UIButton *)button;

@end

@interface LJRecorderBottomView : UIView

@property(nonatomic,weak) id <LJRecorderBottomViewDelegate>delegate;
- (void)hiddenLocationButton:(BOOL)hidden;

@end
