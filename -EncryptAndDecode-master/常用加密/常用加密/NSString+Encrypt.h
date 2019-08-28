//
//  NSString+Encrypt.h
//  常用加密
//
//  Created by LiJie on 2018/7/9.
//  Copyright © 2018年 LiJieView. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encrypt)

#pragma mark - Base64

/**
 base64编码
 
 @return  编码后的文本
 */
- (NSString *)encryptWithBase64;

/**
 base64解码
 
 @return 解码后的文本
 */
- (NSString *)decipherWithBase64;

#pragma mark - MD5
/**
 *  MD5加密, 32位 小写
 *
 *  @return 返回加密后的字符串
 */
- (NSString *)MD5ForLower32Bate;

/**
 *  MD5加密, 32位 大写
 *
 *  @return 返回加密后的字符串
 */
- (NSString *)MD5ForUpper32Bate;

/**
 *  MD5加密, 16位 小写
 *
 *  @return 返回加密后的字符串
 */
- (NSString *)MD5ForLower16Bate;

/**
 *  MD5加密, 16位 大写
 *
 *  @return 返回加密后的字符串
 */
- (NSString *)MD5ForUpper16Bate;

/**
 MD5加盐
 *  @param salt 盐值
 *
 *  @return 加密后的字符串
 */
- (NSString *)MD5AddSaltString:(NSString *)salt;

#pragma mark - AES + BASE64

/**
 *  加密
 *
 *  @return 加密后的字符串
 */

- (NSString *)AESEncrypt;

/**
 *  解密
 *
 *  @return 解密后的内容
 */
-  (NSString *)AESDecrypt;

@end
