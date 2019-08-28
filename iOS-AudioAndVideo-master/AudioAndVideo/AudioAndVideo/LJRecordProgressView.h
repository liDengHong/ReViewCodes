//
//  LJRecordProgressView.h
//  AudioAndVideo
//
//  Created by LiJie on 2017/3/3.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJRecordProgressView : UIView
@property(nonatomic,assign)  CGFloat progress;    /**< 当前进度 >**/
@property(nonatomic,strong)  UIColor *progressColor;  /**< 进度条颜色 >**/
@property(nonatomic,strong)  UIColor *progressBackgroundColor; /**< 进度条背景颜色 >**/
@property(nonatomic,assign)  CGFloat loadProgress;  /**< 加载好的进度 >**/
@property(strong, nonatomic) UIColor *loadProgressColor;    /**< 已经加载好的进度颜色 >**/

@end
