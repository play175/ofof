//
//  OfOfMD5.m
//  ofof
//
//  Created by play175 on 2023/6/12.
//

#import "OfOfMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation OfOfMD5

+ (NSString *)getFileMD5:(NSString *)fliePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if( [fileManager fileExistsAtPath:fliePath isDirectory:nil] )
    {
        NSData *data = [NSData dataWithContentsOfFile:fliePath];
        if(!data){
            return @"";
        }
        return [self getDataMD5:data];
    }else{
        return @"";
    }
}

+ (NSString *)getDataMD5:(NSData *)data
{
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5( data.bytes, (CC_LONG)data.length, digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ )
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@end
