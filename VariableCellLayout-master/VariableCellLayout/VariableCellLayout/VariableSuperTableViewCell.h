//
//  VariableSuperTableViewCell.h
//  VariableCellLayout
//
//  Created by lijie on 2017/2/6.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import <UIKit/UIKit.h>
//基类 cell 所有的 cell 继承与此类
@interface VariableSuperTableViewCell : UITableViewCell
@property (nonatomic, weak) UILabel *titleTextLabel;
@end
//图片轮播 cell
@interface LookImageCell : VariableSuperTableViewCell
@end
//价格 cell
@interface PriceCell : VariableSuperTableViewCell
@end
// 正标题 cell
@interface TitleCell : VariableSuperTableViewCell
@end
//副标题 cell
@interface SubheadingCell : VariableSuperTableViewCell
@end
//支付方式 cell
@interface PayMethodCell : VariableSuperTableViewCell
@end
//促销信息 cell
@interface PromotionalCell : VariableSuperTableViewCell
@end
//商品规格 cell
@interface GoodsRuleCell : VariableSuperTableViewCell
@end
//送货地址 cell
@interface AdressCell : VariableSuperTableViewCell
@end
//标签 cell
@interface MarkCell : VariableSuperTableViewCell
@end
//评价 cell
@interface CommentCell : VariableSuperTableViewCell
@end
//商铺 cell
@interface StoreCell : VariableSuperTableViewCell
@end
//推荐 cell
@interface RecommendCell : VariableSuperTableViewCell
@end


