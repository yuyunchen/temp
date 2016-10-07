//
//  NSString+stringEncrypt.m
//  sliderDemo
//
//  Created by yuyun chen on 16/10/7.
//  Copyright © 2016年 yuyun chen. All rights reserved.
//

#import "NSString+stringEncrypt.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (stringEncrypt)

//MD5加密
- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

@end
