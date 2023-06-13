//
//  OfOfDownload.h
//  ofof
//
//  Created by play175 on 2023/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OfOfDownload : NSObject

+ (void)downloadContentWithUrlString:(NSString *)urlString progressHandler:( void (^)(int percent))progressHandler completionHandler:(void (^)(BOOL ok,int code,NSString *msg,  NSData * _Nullable content))completionHandler;

+ (void)downloadFileWithUrlString:(NSString *)urlString progressHandler:(void (^)(int percent)) progressHandler completionHandler:(void (^)(BOOL ok,int code,NSString *msg,  NSString * _Nullable path))completionHandler;

@end

NS_ASSUME_NONNULL_END
