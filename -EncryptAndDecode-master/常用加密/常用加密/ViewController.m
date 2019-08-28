//
//  ViewController.m
//  常用加密
//
//  Created by LiJie on 2018/7/9.
//  Copyright © 2018年 LiJieView. All rights reserved.
//

#import "ViewController.h"
#import "NSString+Encrypt.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *string = @"hahaha";
//    NSString *base64String = [string MD5ForUpper16Bate];
//    NSLog(@"base64String : %@",base64String);
//
//    NSString *sourceString = [base64String decipherWithBase64];
//    NSLog(@"sourceString : %@",sourceString);
    
    NSString *aesString = [@"我是一只小小鸟" AESEncrypt];
    NSLog(@"aesString: %@",aesString);
    NSString *deAesString = [aesString AESDecrypt];
    NSLog(@"deAesString: %@",deAesString);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
