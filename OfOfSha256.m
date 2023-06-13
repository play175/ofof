//
//  OfOfSha256.m
//  ofof
//
//  Created by play175 on 2023/6/12.
//

#import "OfOfSha256.h"
#import <CommonCrypto/CommonDigest.h>

@implementation OfOfSha256

+ (NSString *)sha256:(NSString *) content
{
    if(!content) return nil;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256( data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for( int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@end
