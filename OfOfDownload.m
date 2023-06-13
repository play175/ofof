//
//  OfOfDownload.m
//  ofof
//
//  Created by play175 on 2023/6/12.
//

#import "OfOfDownload.h"

@interface OfOfDownload ()<NSURLSessionDownloadDelegate>

@property (nonatomic,copy) void (^progressHandler)(int percent);
@property (nonatomic,copy) void (^completionHandler)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error);

@end

@implementation OfOfDownload

/**
 下载文件并直接返回文件内容
 */
+ (void)downloadContentWithUrlString:(NSString *)urlString progressHandler:( void (^)(int percent))progressHandler completionHandler:(void (^)(BOOL ok,int code,NSString *msg,  NSData * _Nullable content))completionHandler
{
    NSURLSessionConfiguration *scf = [NSURLSessionConfiguration defaultSessionConfiguration];
    OfOfDownload *instance = [[OfOfDownload alloc] init];
    instance.progressHandler = progressHandler;
    instance.completionHandler = ^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSInteger statusCode = [httpResponse statusCode];
        NSString *statusText = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
        
        if (error || statusCode != 200) {
            completionHandler(NO,(int)statusCode, [@"download failed：" stringByAppendingString:error != nil ? [error description] : statusText ],nil);
        }else{
            NSData *content = [NSData dataWithContentsOfURL:location];
            completionHandler(YES,200,@"download ok",content);
        }
     };
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:scf delegate:instance delegateQueue:[[NSOperationQueue alloc] init]];
    [[session downloadTaskWithURL:[NSURL URLWithString:urlString]] resume];
}

/**
 下载文件并保存到缓存目录
 */
+ (void)downloadFileWithUrlString:(NSString *)urlString progressHandler:(void (^)(int percent)) progressHandler completionHandler:(void (^)(BOOL ok,int code,NSString *msg,  NSString * _Nullable path))completionHandler
{
    NSURLSessionConfiguration *scf = [NSURLSessionConfiguration defaultSessionConfiguration];
    OfOfDownload *instance = [[OfOfDownload alloc] init];
    instance.progressHandler = progressHandler;
    instance.completionHandler =^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSInteger statusCode = [httpResponse statusCode];
        NSString *statusText = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
        
        if (error || statusCode != 200) {
            NSString *msg = [@"download failed:" stringByAppendingString:error != nil ? [error description] : statusText ];
                completionHandler(NO,(int)statusCode, msg,@"");
        }else{
            NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[@"ofofdownload-" stringByAppendingString:response.suggestedFilename]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:fullPath] error:nil];
            }
            BOOL moveSucces= [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
            if (moveSucces) {
                completionHandler(YES,200,@"download ok",fullPath);
            }else{
                completionHandler(NO,500,@"file move faild",@"");
            }
        }
    };
    NSURLSession *session = [NSURLSession sessionWithConfiguration:scf delegate:instance delegateQueue:[[NSOperationQueue alloc] init]];
    [[session downloadTaskWithURL:[NSURL URLWithString:urlString]] resume];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    int percent = (int)(100.0*totalBytesWritten / totalBytesExpectedToWrite);
    if (self.progressHandler) {
        self.progressHandler(percent);
    }
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    if (self.completionHandler) {
        self.completionHandler(location,downloadTask.response,nil);
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(error){
        if (self.completionHandler) {
            self.completionHandler(nil,task.response,error);
        }
    }
}


@end
