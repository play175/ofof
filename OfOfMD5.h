//
//  OfOfMD5.h
//  ofof
//
//  Created by play175 on 2023/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OfOfMD5 : NSObject

+ (NSString *)getFileMD5:(NSString *)fliePath;

+ (NSString *)getDataMD5:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
