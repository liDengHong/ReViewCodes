
//
//  LJTestCollectionViewController.m
//  根据 ScollView 操作导航栏的透明度
//
//  Created by LiJie on 2017/4/11.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJTestCollectionViewController.h"
#import "UIViewController+LJNavHidden.h"

@interface LJTestCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *collectionView;
@end

@implementation LJTestCollectionViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self lj_viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self lj_viewWillDisappear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];

    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectZero];
    lable.text = @"我是 ColectionView";
    lable.textColor = [UIColor greenColor];
    [lable sizeToFit];
    self.navigationItem.titleView = lable;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:[UIButton buttonWithType:UIButtonTypeInfoDark]];
    self.navigationItem.rightBarButtonItem = item;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
    UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = itemRight;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self setScrollView:self.collectionView scrollViewOffsetY:500 options:LJNavBarHiddenTwoOptionsLeftItem|LJNavBarHiddenTwoOptionsTitleItem];
    [self setNavBarBackgoundImage:[UIImage imageNamed:@"123"]];

}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(170, 200);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(30, 20, 20, 20);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 40;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    
    return cell;
}

@end
