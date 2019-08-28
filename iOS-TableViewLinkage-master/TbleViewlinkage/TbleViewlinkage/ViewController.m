//
//  ViewController.m
//  TbleViewlinkage
//
//  Created by LiJie on 2018/4/9.
//  Copyright © 2018年 LiJie. All rights reserved.
//


#import "ViewController.h"
#import "TableViewController.h"
#import "CollectionViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        TableViewController *tableViewVC = [[TableViewController alloc] init];
        [self.navigationController pushViewController:tableViewVC animated:YES];
    }else {
        CollectionViewController *collectionVC = [[CollectionViewController alloc] init];
        [self.navigationController pushViewController:collectionVC animated:YES];
    }
}


@end
