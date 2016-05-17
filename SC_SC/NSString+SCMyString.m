//
//  NSString+SCMyString.m
//  GWSignIn
//
//  Created by 广为网络 on 16/4/19.
//  Copyright © 2016年 广为网络. All rights reserved.
//

#import "NSString+SCMyString.h"

@implementation NSString (SCMyString)
//通过此方法加密的事32位的
+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH *2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
}
//将32位的MD字符串 转化成16位的M的字符串
+ (NSString *)trransFromMD532ToMD516:(NSString *)MD532{
    NSString  * string;
    for (int i=0; i<24; i++) {
        string=[MD532 substringWithRange:NSMakeRange(8, 16)];
    }
    return string;
}
@end
