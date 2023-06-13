//
//  OfOfGunzip.h
//  ofof
//
//  Created by play175 on 2023/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OfOfGunzip : NSObject

+ (NSData *)gunzip: (NSData *)gzipData;

@end

NS_ASSUME_NONNULL_END
