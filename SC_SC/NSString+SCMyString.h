//
//  NSString+SCMyString.h
//  GWSignIn
//
//  Created by 广为网络 on 16/4/19.
//  Copyright © 2016年 广为网络. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (SCMyString)
+ (NSString *)md5:(NSString *)str;
+ (NSString *)trransFromMD532ToMD516:(NSString *)MD532;
@end
