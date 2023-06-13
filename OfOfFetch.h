//
//  OfOfFetch.h
//  ofof
//
//  Created by play175 on 2023/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OfOfFetch : NSObject
+ (void)fetchWithUrlString:(NSString *)urlString options:(NSDictionary *)options progressHandler:(void (^)(int percent))progressHandler completionHandler:(void (^)(BOOL ok,int code,NSString *msg,  NSDictionary * _Nullable response))completionHandler;

@end

NS_ASSUME_NONNULL_END
