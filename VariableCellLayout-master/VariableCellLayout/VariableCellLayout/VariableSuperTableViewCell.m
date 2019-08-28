
//
//  VariableSuperTableViewCell.m
//  VariableCellLayout
//
//  Created by lijie on 2017/2/6.
//  Copyright © 2017年 lijie. All rights reserved.
// 导航栏 -> 轮播图片展示 -> 价格 -> 正标题 -> 副标题 -> 支付方式 -> 促销信息 -> 可选规格 -> 送货地址 -> 特色标签 -> 评价 -> 店铺信息 -> 为你推荐

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#import "VariableSuperTableViewCell.h"
@implementation VariableSuperTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH,44)];
        lable.numberOfLines = 0;
        [self.contentView addSubview:lable];
        self.titleTextLabel = lable;
    }
    return self;
}
@end

@implementation LookImageCell
@end

@implementation PriceCell

@end

@implementation TitleCell

@end

@implementation SubheadingCell

@end

@implementation PayMethodCell

@end

@implementation PromotionalCell

@end

@implementation GoodsRuleCell

@end

@implementation AdressCell

@end

@implementation MarkCell

@end
// 评论内容cell使用Auto Layout，配合iOS 8 TableView的自动算高，实现内容自适应
@implementation CommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //把系统自动布局转化为约束布局, 禁用系统的自动布局
        self.titleTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleTextLabel.preferredMaxLayoutWidth = SCREENWIDTH - 8;
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.titleTextLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:4.0f];
        
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.titleTextLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-4.0f];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.titleTextLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:4.0f];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.titleTextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:- 4.0f];
        
        [self.contentView addConstraints:@[leftConstraint,rightConstraint,topConstraint,bottomConstraint]];
    }
    return self;
}

@end

@implementation StoreCell

@end

@implementation RecommendCell

@end
