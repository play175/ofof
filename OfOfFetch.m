//
//  OfOfFetch.m
//  ofof
//
//  Created by play175 on 2023/6/12.
//

#import "OfOfFetch.h"

@interface OfOfFetch ()<NSURLSessionDataDelegate>

// progress handle
@property (nonatomic,copy) void (^progressHandler)(int percent);

@end

@implementation OfOfFetch

/**
 fetch的实现
 */
+ (void)fetchWithUrlString:(NSString *)urlString options:(NSDictionary *)options progressHandler:(void (^)(int percent))progressHandler completionHandler:(void (^)(BOOL ok,int code,NSString *msg,  NSDictionary * _Nullable response))completionHandler
{
    NSDictionary *headers = options[@"headers"] ? options[@"headers"] : @{};
    NSString *method = options[@"method"] ? [options[@"method"] uppercaseString]: @"GET";
    NSDictionary *bodyData = options[@"data"] ? options[@"data"] : @{};
    NSDictionary *files = options[@"files"] ? options[@"files"] : @{};
    NSTimeInterval timeout = options[@"timeout"] ? [options[@"timeout"] timeInterval] : 15;
    NSString *contentType = headers[@"Content-type"] ? headers[@"Content-type"] : headers[@"Content-Type"] ? headers[@"Content-Type"] : headers[@"Content-type"] ? headers[@"Content-type"] : headers[@"content-type"] ? headers[@"content-type"] : @"";
        
    if(!([@"GET" isEqualToString:method] || [@"POST" isEqualToString:method])){
            completionHandler(NO,400,@"method not support",nil);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = method;
    [request setTimeoutInterval:timeout];
    
    [request setAllHTTPHeaderFields:headers];
    
    if([@"POST" isEqualToString:method]){
                
        if((files != nil && files.allKeys.count > 0) || [contentType containsString:@"multipart/form-data"]){
            NSMutableData *body = [NSMutableData data];
            
            char rdata[32];
            for (int x=0;x < 32;rdata[x++] = (char)('A' + (arc4random_uniform(26))));
            NSString *boundary = [[NSString alloc] initWithBytes:rdata length:6 encoding:NSUTF8StringEncoding];
                        
            [bodyData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *fieldName = key;
                NSString *fieldValue = obj;
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", fieldName] dataUsingEncoding:NSUTF8StringEncoding]];
                
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[fieldValue dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }];
            
            [files enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *fieldName = key;
                NSDictionary *fileInfo = obj;
                NSString *fileName = [fileInfo.allKeys containsObject: @"fileName"] ? fileInfo[@"fileName"] : fieldName;
                id fileContentRef = fileInfo[@"fileContent"];
                NSData *fileData;
                if(fileContentRef != nil && [fileContentRef isKindOfClass:[NSData class]]){
                    fileData = (NSData *)fileContentRef;
                }else if(fileContentRef != nil && [fileContentRef isKindOfClass:[NSString class]]){
                    NSString *fileContentStr = (NSString *)fileContentRef;
                    if([fileContentStr hasPrefix:@"data:"]){
                        NSRange pos =  [fileContentStr rangeOfString:@","];
                        if(pos.location != NSNotFound){
                            fileData = [[NSData alloc]initWithBase64EncodedString: [fileContentStr substringFromIndex:pos.location+1] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        }else{
                            NSURL *dataUrl = [NSURL URLWithString:fileContentStr];
                            fileData = [NSData dataWithContentsOfURL:dataUrl];
                        }
                    }else{
                        fileData = [NSData dataWithContentsOfFile:fileContentStr];
                    }
                }
                
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:(fileData)];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }];
            
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [request setValue:[NSString stringWithFormat:@"%zd", body.length] forHTTPHeaderField:@"Content-Length"];
            [request setValue:[NSString stringWithFormat: @"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
            
            request.HTTPBody = body;
        }else if([contentType containsString:@"x-www-form-urlencoded"]){
            NSMutableString *urlencoded = @"".mutableCopy;
            [bodyData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *fieldName = key;
                NSString *fieldValue = obj;
                NSString *encodedValue = [fieldValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                if(urlencoded.length >0){
                    [urlencoded appendString:@"&"];
                }
                [urlencoded appendFormat:@"%@=%@",fieldName,encodedValue];
            }];
            NSData *body = [urlencoded dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:body];
            [request setAllHTTPHeaderFields:@{@"Content-Type":@"application/x-www-form-urlencoded; charset=utf-8"}];
        }else {
            NSData *body = [NSJSONSerialization dataWithJSONObject:bodyData options:0 error:NULL];
            [request setHTTPBody:body];
            [request setAllHTTPHeaderFields:@{@"Content-Type":@"application/json; charset=utf-8"}];
        }
    }
    
    NSURLSessionConfiguration *scf = [NSURLSessionConfiguration defaultSessionConfiguration];
    OfOfFetch *instance = nil;
    if(progressHandler){
        instance = [[OfOfFetch alloc] init];
        instance.progressHandler = progressHandler;
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:scf delegate:instance delegateQueue:[[NSOperationQueue alloc] init]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSString *responseText = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
        NSInteger statusCode = [httpResponse statusCode];
//        NSLog(@"请求:%@ 请求类型:%@ 请求参数:%@ 返回状态码：%ld 返回内容:%@",urlString,method,bodyData,(long)statusCode,responseText);
        
        __block NSMutableDictionary *res = [[NSMutableDictionary alloc] init];
        if (statusCode == 200 && data) {
            if([responseText hasPrefix:@"{"]){
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                res[@"responseType"] = @"json";
                res[@"responseData"] = dict;
                    completionHandler(YES,200,@"ok",res);
            }else{
                res[@"responseType"] = @"text";
                res[@"responseData"] = responseText;
                    completionHandler(YES,200,@"ok",res);
            }
        } else {
            res[@"responseType"] = @"text";
            res[@"responseData"] = responseText;
            __block NSString *msg = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
            if(error){
                msg = [error description];
                msg = [msg stringByAppendingString:urlString];
            }
                completionHandler(NO,(int)statusCode,msg,res);
        }
    }] resume];
      
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    int percent = (int)(100.0*totalBytesSent / totalBytesExpectedToSend);
    if (self.progressHandler) {
        self.progressHandler(percent);
    }
}
@end
