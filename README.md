# ofof
One-function-one-file in Objective-C

## fetch
`+ (void)fetchWithUrlString:(NSString *)urlString options:(NSDictionary *)options progressHandler:(void (^)(int percent))progressHandler completionHandler:(void (^)(BOOL ok,int code,NSString *msg,  NSDictionary * _Nullable response))completionHandler;`

- example1:post
```objc
[OfOfFetch fetchWithUrlString:@"https://example.com/post_test" options:@{
        @"method":@"POST",
        @"headers":@{
                @"content-type": @"application/json; charset=utf-8"
        },
        @"data":@{
            @"name":@"app1",
            @"value":@"value1",
        },
    } progressHandler:^(int percent) {
        NSLog(@"post progress:%d",percent);
    } completionHandler:^(BOOL ok, int code, NSString * _Nonnull msg, NSDictionary * data) {
        NSLog(@"fetch response:%@ %@",msg,data);
}];
```

- example2:upload
```objc
[OfOfFetch fetchWithUrlString:@"https://example.com/upload_test" options:@{
        @"method":@"POST",
        @"headers":@{
                @"content-type": @"multipart/form-data; charset=utf-8"
        },
        @"data":@{
            @"name":@"app1",
            @"value":@"value1",
        },
        @"files":@{
            @"avatar":@{
                @"fileName":@"file1.png",
                @"fileContent":fileData, // file content format in NSData*
            },
        @"banner":@{
                @"fileName":@"file2.png",
                @"fileContent":@"data:image/png;base64,iVBORw0KGgoAAAAN......", // file content format in data-url string
            }
        },
    } progressHandler:^(int percent) {
        NSLog(@"post progress:%d",percent);
    } completionHandler:^(BOOL ok, int code, NSString * _Nonnull msg, NSDictionary * data) {
        NSLog(@"fetch response:%@ %@",msg,data);
}];
```

## download

`+ (void)downloadContentWithUrlString:(NSString *)urlString progressHandler:( void (^)(int percent))progressHandler completionHandler:(void (^)(BOOL ok,int code,NSString *msg,  NSData * _Nullable content))completionHandler;`

`+ (void)downloadFileWithUrlString:(NSString *)urlString progressHandler:(void (^)(int percent)) progressHandler completionHandler:(void (^)(BOOL ok,int code,NSString *msg,  NSString * _Nullable path))completionHandler;`

- example
```objc
[OfOfDownload downloadFileWithUrlString:@"https://example.com/static/demo.zip" progressHandler:^(int percent)    {
        NSLog(@"downloadFileWithUrlString progress:%d",percent);
    } completionHandler:^(BOOL ok, int code, NSString * _Nonnull msg, NSString * _Nullable path) {
        if(!ok){
            // download not success
        }else{
            // TODO process with download file cache save path (path)
            NSLog(@"downloadFileWithUrlString:%@ %@",msg,path);
        }
}];
```

## unzip gz file
- `+ (NSData *)gunzip: (NSData *)gzipData`

## sha256
- `+ (NSString *)sha256:(NSString *) content`

## md5
- `+ (NSString *)getFileMD5:(NSString *)fliePath`
- `+ (NSString *)getDataMD5:(NSData *)data`
