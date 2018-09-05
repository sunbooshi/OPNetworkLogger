//
//  OPNetworkLogger.m
//  OPNetworkLogger
//
//  Created by sunboshi on 2018/9/3.
//  Copyright © 2018年 sunobshi.tech. All rights reserved.
//

#import "OPNetworkLogger.h"
#import "SKNetworkReporter.h"
#import "FLEXNetworkObserver.h"
#import "FLEXNetworkRecorder.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

@interface OPNetworkLogger() <SKNetworkReporterDelegate>

@property (nonatomic, strong) NSMutableDictionary *requests;
@property (nonatomic, strong) NSMutableArray *all;
@property (nonatomic, strong) dispatch_queue_t workqueue;
@property (nonatomic, strong) GCDWebServer *webServer;

@end

@implementation OPNetworkLogger

+ (instancetype)defaultLogger {
    static id logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[OPNetworkLogger alloc] init];
    });
    return logger;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.all = [NSMutableArray array];
        self.requests = [NSMutableDictionary dictionary];
        self.workqueue = dispatch_queue_create("network-logger", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)start {
    [FLEXNetworkObserver start];
    [FLEXNetworkRecorder defaultRecorder].delegate = self;
}

#pragma mark - SKNetworkReporterDelegate

- (void)didObserveRequest:(SKRequestInfo *)request;
{
    dispatch_async(self.workqueue, ^{
        [self.requests setObject:request forKey:@(request.identifier)];
    });
}

- (void)didObserveResponse:(SKResponseInfo *)response
{
    dispatch_async(self.workqueue, ^{
        [self merageWithResponse:response];
    });
}

- (void)merageWithResponse:(SKResponseInfo *)response {
    SKRequestInfo *request = self.requests[@(response.identifier)];
    if (request == nil) {
        NSLog(@"error: no request found");
        return;
    }
    
    NSMutableArray<NSDictionary<NSString *, id> *> *requestHeaders = [NSMutableArray new];
    for (NSString *key in [request.request.allHTTPHeaderFields allKeys]) {
        NSDictionary<NSString *, id> *header = @{
                                                 @"key": key,
                                                 @"value": request.request.allHTTPHeaderFields[key]
                                                 };
        [requestHeaders addObject: header];
    }
    
    NSString *requestData = request.body;

    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response.response;
    
    NSMutableArray<NSDictionary<NSString *, id> *> *responseHeaders = [NSMutableArray new];
    for (NSString *key in [httpResponse.allHeaderFields allKeys]) {
        NSDictionary<NSString *, id> *header = @{
                                                 @"key": key,
                                                 @"value": httpResponse.allHeaderFields[key]
                                                 };
        [responseHeaders addObject: header];
    }
    
    NSString *responseData = response.body;

    NSDictionary *data = @{
                           @"id": @(request.identifier),
                           @"duration": @(response.timestamp - request.timestamp),
                           @"method": request.request.HTTPMethod ?: [NSNull null],
                           @"url": [request.request.URL absoluteString] ?: [NSNull null],
                           @"requestHeaders": requestHeaders,
                           @"requestData": requestData ? requestData : [NSNull null],
                           @"status": @(httpResponse.statusCode),
                           @"reason": [NSHTTPURLResponse localizedStringForStatusCode: httpResponse.statusCode] ?: [NSNull null],
                           @"responseHeaders": responseHeaders,
                           @"responseData": responseData ? responseData : [NSNull null]
                           };
    
    [self.all addObject:data];
    [self.requests removeObjectForKey:@(request.identifier)];
}

- (NSArray *)allRequests {
    return self.all;
}

- (NSArray *)searchRequest:(NSString *)url {
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSDictionary *item in self.all) {
        NSString *url = item[@"url"];
        if ([NSNull isEqual:url]) {
            continue;
        }
        NSRange range = [url rangeOfString:url options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [results addObject:item];
        }
    }
    
    if (results.count > 0) {
        return results;
    }
    return nil;
}

- (NSString *)jsonData {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.all options:NSJSONWritingPrettyPrinted error:&error];
    if (! jsonData) {
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (NSString *)index {
    return @"<html> <header> <title>OPNetworkLogger</title> <style> .container { margin-left: auto; margin-right: auto; width: 560px; margin-top: 60px; padding: 20px; border:1px solid #eeeeee; border-radius: 6px; text-align: center; } h2 { color: #666666; } </style> <body> <div class=\"container\"> <h2>OPNetworkLogger</h2> <p>简单粗暴但却很有用的网络请求日志！</p> <a href=\"/logparser\">点击这里访问日志</a> <br/> <div style=\"margin-top:20px;\"> <a href=\"https://github.com/sunboshi/OPNetworkLogger\">GitHub</a> </div> </div> </body> </html>";
}

+ (NSString *)logparser {
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"logparser" ofType:@"html"];
    NSString *jsPath = [[NSBundle mainBundle] pathForResource:@"logparser" ofType:@"js"];
    NSError *error = nil;
    NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return @"load html error!";
    }
    
    NSString *js = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return @"load js error!";
    }
    
    return [NSString stringWithFormat:html, js];
}

- (void)startWebServer {
    self.webServer = [[GCDWebServer alloc] init];
    
    // Add a handler to respond to GET requests on any URL
    [self.webServer addDefaultHandlerForMethod:@"GET"
                              requestClass:[GCDWebServerRequest class]
                              processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                  return [GCDWebServerDataResponse responseWithHTML:[OPNetworkLogger index]];
                              }];
    
    [self.webServer addHandlerForMethod:@"GET" path:@"/log" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        GCDWebServerDataResponse *response = [GCDWebServerDataResponse responseWithJSONObject:[[OPNetworkLogger defaultLogger] allRequests]];
        [response setValue:@"*" forAdditionalHeader:@"Access-Control-Allow-Origin"];
        return response;
    }];
    
    [self.webServer addHandlerForMethod:@"GET" path:@"/logparser" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        GCDWebServerDataResponse *response = [GCDWebServerDataResponse responseWithHTML:[OPNetworkLogger logparser]];
        return response;
    }];
    
    // Start server on port 10086
    [self.webServer startWithPort:10086 bonjourName:nil];
    NSLog(@"Visit %@ in your web browser", _webServer.serverURL);
}

@end
