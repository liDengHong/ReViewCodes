//
//  NSString+Encrypt.m
//  常用加密
//
//  Created by LiJie on 2018/7/9.
//  Copyright © 2018年 LiJieView. All rights reserved.
//

#import "NSString+Encrypt.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

static NSString *const KEY = @"TESTPASSWORD";
static NSString *const IV = @"AES00IVPARAMETER";

@implementation NSString (Encrypt)

#pragma mark - Base64
#pragma mark-Base64编码
- (NSString *)encryptWithBase64 {
    if ([self judgeEmptyWithString:self]) {
        return @"";
    }
    //判断设备系统是否满足条件(支持iOS7及以后的系统版本)
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] <= 6.9) {
        return @"";
    }
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    /**
     NSDataBase64Encoding64CharacterLineLength其作用是将生成的Base64字符串按照64个字符长度进行等分换行。
     NSDataBase64Encoding76CharacterLineLength其作用是将生成的Base64字符串按照76个字符长度进行等分换行。
     NSDataBase64EncodingEndLineWithCarriageReturn其作用是将生成的Base64字符串以回车结束。
     NSDataBase64EncodingEndLineWithLineFeed其作用是将生成的Base64字符串以换行结束。
     */
    NSString *base64String = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return base64String;
}

#pragma mark-Base64解码
- (NSString *)decipherWithBase64 {
    if ([self judgeEmptyWithString:self]) {
        return @"";
    }
    //判断设备系统是否满足条件(支持iOS7及以后的系统版本)
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] <= 6.9) {
        return @"";
    }
    NSData *sourceData = [[NSData alloc] initWithBase64EncodedString:self options:0];
    /**
     NSDataBase64DecodingIgnoreUnknownCharacters 忽略无法识别的字符
     */
    NSString *sourceString = [[NSString alloc] initWithData:sourceData encoding:NSUTF8StringEncoding];
    return sourceString;
}

#pragma mark - MD5
#pragma mark-32位 小写
- (NSString *)MD5ForLower32Bate {
    if ([self judgeEmptyWithString:self]) {
        return @"";
    }
    //要进行UTF8的转码
    const char* input = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return digest;
}

///
#pragma mark-32位 大写
- (NSString *)MD5ForUpper32Bate {
    if ([self judgeEmptyWithString:self]) {
        return @"";
    }
    //要进行UTF8的转码
    const char* input = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }
    return digest;
}

#pragma mark-16位 大写
- (NSString *)MD5ForUpper16Bate {
    if ([self judgeEmptyWithString:self]) {
        return @"";
    }
    NSString *md5Str = [self MD5ForUpper32Bate];
    NSString  *string;
    for (int i=0; i<24; i++) {
        string=[md5Str substringWithRange:NSMakeRange(8, 16)];
    }
    return string;
}

#pragma mark-16位 小写
- (NSString *)MD5ForLower16Bate {
    if ([self judgeEmptyWithString:self]) {
        return @"";
    }
    NSString *md5Str = [self MD5ForLower32Bate];
    NSString  *string;
    for (int i=0; i<24; i++) {
        string=[md5Str substringWithRange:NSMakeRange(8, 16)];
    }
    return string;
}

#pragma mark-加盐
- (NSString *)MD5AddSaltString:(NSString *)salt {
    NSString *md5String = [[self MD5ForLower32Bate] stringByAppendingString:salt];
    return [md5String MD5ForUpper16Bate];
}

#pragma mark - AES + BASE64
#pragma mark-加密
- (NSString *)AESEncrypt {
    if ([self judgeEmptyWithString:self]) {
        return @"";
    }
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *AESData = [self AES128operation:kCCEncrypt data:data key:KEY iv:IV];
    //base64编码
    NSString *base64String = [AESData base64EncodedStringWithOptions:0];
    return base64String;
}

#pragma mark-解密
- (NSString *)AESDecrypt {
    if ([self judgeEmptyWithString:self]) {
        return @"";
    }
    // 先 base64解码
    NSData *Base64Data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    NSData *AESData = [self AES128operation:kCCDecrypt data:Base64Data key:KEY iv:IV];
    NSString *string = [[NSString alloc] initWithData:AESData encoding:NSUTF8StringEncoding];
    return string;
}

#pragma mark-加解密算法
- (NSData *)AES128operation:(CCOperation)operation data:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    
    /** key*/ //(key 值的加密方式)
    char keyPtr[kCCKeySizeAES128 + 1];  //kCCKeySizeAES128是加密位数 (加密后数据的位数)  + 1是因为getCString方法中需要
    bzero(keyPtr, sizeof(keyPtr));  //参数s为内存（字符串）指针，n 为需要清零的字节数。bzero()会将参数s 所指的内存区域前n 个字节，全部设为零值。
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding]; //处理成要加密方式的 C 字符
    
    /** IV*/ // (AES的 iv 只支持16位)
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    /**
     *
     *              返回操作的状态
     *
     op                     : 加密或者解密
     alg                    : 加密算法
     options                : 设置加密模式 等参数 kCCOptionPKCS7Padding等
     key                    : 加密的 key 值 C 字符
     keyLength              : key 的长度
     iv                     : 加密的偏移量
     dataIn                 : 要加密或解密的数据
     dataInLength           : 要加密或解密的数据的长度
     dataOut                : 加密结果的承载体
     dataOutAvailable       : 返回结果的长度
     dataOutMoved           : 提供所需要的缓冲空间
     */
    CCCryptorStatus cryptorStatus = CCCrypt(operation, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyPtr, kCCKeySizeAES128, ivPtr, [data bytes], [data length], buffer, bufferSize, &numBytesEncrypted);
    if(cryptorStatus == kCCSuccess) {
        NSLog(@"Success");
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    } else {
        NSLog(@"Error");
    }
    free(buffer);
    return nil;
}


#pragma mark - 判空
- (BOOL)judgeEmptyWithString:(NSString *)string {
    if (!string) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!string.length) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [string stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}

@end
