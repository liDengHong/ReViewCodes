//
//  ViewController.m
//  VariableCellLayout
//
//  Created by lijie on 2017/2/6.
//  Copyright © 2017年 lijie. All rights reserved.
//

/*
 界面需求 :
 导航栏 -> 轮播图片展示 -> 价格 -> 正标题 -> 副标题 -> 促销信息 -> 支付方式 -> 可选规格 -> 送货地址  -> 评价 -> 店铺信息 -> 为你推荐
 
 此 demo 以一个label 控件填充每一个展示 cell;
 
 业务逻辑: 1.促销信息, 可选规格, 特色标签, 这些内容是可选的, 不是每一件商品都有促销的, 也不是每一件商品的规格和特色标签是固定的.
 2.在刚进入页面时首先会从上一个界面把商品图片和正标题传过来, 其他数据是重新请求网络数据的.
 */

#import "ViewController.h"
#import "VariableSuperTableViewCell.h"
#import "ToolsClass.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UIButton *loadButton;
@property (nonatomic, strong) NSMutableArray<NSArray<ToolsClass *> *> *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self setupData];
}

#pragma mark -  UI
- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"商品展示";
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"刷新数据" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(reloadGoodsData) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 70, 50);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStyleGrouped];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.sectionFooterHeight = CGFLOAT_MIN;
    self.tableView.tableFooterView = [[UIView alloc] init];
    //在此处设置tableHeaderView是为了解决 tableView 在 group 风格时导航栏下面的空白,
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, CGFLOAT_MIN)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[LookImageCell class] forCellReuseIdentifier:@"lookImage"];
    [self.tableView registerClass:[PriceCell class] forCellReuseIdentifier:@"price"];
    [self.tableView registerClass:[TitleCell class] forCellReuseIdentifier:@"title"];
    [self.tableView registerClass:[SubheadingCell class] forCellReuseIdentifier:@"subheading"];
    [self.tableView registerClass:[PayMethodCell class] forCellReuseIdentifier:@"pay"];
    [self.tableView registerClass:[PromotionalCell class] forCellReuseIdentifier:@"promotional"];
    [self.tableView registerClass:[GoodsRuleCell class] forCellReuseIdentifier:@"goodsRule"];
    [self.tableView registerClass:[AdressCell class] forCellReuseIdentifier:@"adress"];
    [self.tableView registerClass:[MarkCell class] forCellReuseIdentifier:@"mark"];
    [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:@"comment"];
    [self.tableView registerClass:[StoreCell class] forCellReuseIdentifier:@"store"];
    [self.tableView registerClass:[RecommendCell class] forCellReuseIdentifier:@"recommend"];
    [self.view addSubview:self.tableView];
    
}

- (void)setupData {
    
    _dataArray = [NSMutableArray array];
    ToolsClass *imageTool = [[ToolsClass alloc] initWithCellIdentifier:@"lookImage" data:@[@"图片12",@"图片23"] rowHight:120*[UIScreen mainScreen].bounds.size.width / 320.f];
    
    ToolsClass *titleTool = [[ToolsClass alloc] initWithCellIdentifier:@"title" data:@[@"菜鸟手机"] rowHight:44];
    
    [_dataArray addObject:@[imageTool,titleTool]];
}
//模拟从网络获取数据
- (void)reloadGoodsData {
    self.dataArray = [NSMutableArray array];
    _dataArray = [NSMutableArray array];
    
    //图片
    ToolsClass *imageTool = [[ToolsClass alloc] initWithCellIdentifier:@"lookImage" data:@[@"图片1",@"图片22"] rowHight:120*[UIScreen mainScreen].bounds.size.width / 320.f];
    //正标题
    ToolsClass *titleTool = [[ToolsClass alloc] initWithCellIdentifier:@"title" data:@[@"菜鸟手机"] rowHight:44];
    //价格
    ToolsClass *priceTool = [[ToolsClass alloc] initWithCellIdentifier:@"price" data:@"$10000" rowHight:44];
    //副标题
    ToolsClass *subTool = [[ToolsClass alloc] initWithCellIdentifier:@"subheading" data:@"中秋大放送,实惠多多,买就送,速来围观" rowHight:44];
    [_dataArray addObject:@[imageTool,titleTool,subTool,priceTool]];
    //随机出现的
    //促销信息
    if (arc4random() % 2 == 0) {
        ToolsClass *promotionalTool = [[ToolsClass alloc] initWithCellIdentifier:@"promotional" data:@[@"满1999减200",@"满4999减400"] rowHight:44];
        [_dataArray addObject:@[promotionalTool]];
    }
    //支付方式
    ToolsClass *payMethedTool = [[ToolsClass alloc] initWithCellIdentifier:@"pay" data:@[@"微信支付",@"支付宝支付"] rowHight:44];
    //可选规则
    ToolsClass *goodsRuleTool = [[ToolsClass alloc] initWithCellIdentifier:@"goodsRule" data:@"金色, 32G 高配版" rowHight:44];
    //送货地址
    if (arc4random() % 2 == 0) {
        ToolsClass *adressTool = [[ToolsClass alloc] initWithCellIdentifier:@"adress" data:@"北京市,朝阳区" rowHight:44];
        [_dataArray addObject:@[payMethedTool, goodsRuleTool,adressTool]];
        
        [self.tableView reloadData];
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToolsClass *tools = _dataArray[indexPath.section][indexPath.row];
    return tools.rowHight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 10;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray[section].count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToolsClass *row = _dataArray[indexPath.section][indexPath.row];
    if ([row.identifier isEqualToString:@"lookImage"]) {
        LookImageCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier forIndexPath:indexPath];
        NSArray <NSString *>*stringArray = row.data;
        cell.titleTextLabel.text = [stringArray componentsJoinedByString:@"\n"];
        return cell;
    } else if ([row.identifier isEqualToString:@"price"]) {
        
        PriceCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier forIndexPath:indexPath];
        //        NSArray <NSString *>*stringArray = row.data;
        cell.titleTextLabel.text = row.data;
        return cell;
    } else if([row.identifier  isEqualToString:@"title"]) {
        TitleCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier forIndexPath:indexPath];
        NSArray <NSString *>*stringArray = row.data;
        cell.titleTextLabel.text = [stringArray componentsJoinedByString:@"\n"];
        return cell;
    } else if ([row.identifier isEqualToString:@"subheading"]) {
        SubheadingCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier forIndexPath:indexPath];
        cell.titleTextLabel.text = row.data;
        return cell;
    } else if ([row.identifier isEqualToString:@"pay"]) {
        PayMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier forIndexPath:indexPath];
        NSArray <NSString *>*stringArray = row.data;
        cell.titleTextLabel.text = [stringArray componentsJoinedByString:@"  "];
        return cell;
    } else if ([row.identifier isEqualToString:@"promotional"]) {
        PromotionalCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier forIndexPath:indexPath];
        NSArray <NSString *>*stringArray = row.data;
        cell.titleTextLabel.text = [stringArray componentsJoinedByString:@"  "];
        return cell;
    } else if ([row.identifier isEqualToString:@"goodsRule"]) {
        GoodsRuleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsRule" forIndexPath:indexPath];
        cell.titleTextLabel.text = row.data;
        return cell;
    } else if ([row.identifier isEqualToString:@"adress"]) {
        AdressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"adress" forIndexPath:indexPath];
        cell.titleTextLabel.text = row.data;
        return cell;
    }
    return nil;
}
@end
