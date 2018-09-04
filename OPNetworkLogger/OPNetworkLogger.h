//
//  OPNetworkLogger.h
//  OPNetworkLogger
//
//  Created by sunboshi on 2018/9/3.
//  Copyright © 2018年 sunobshi.tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPNetworkLogger : NSObject

+ (instancetype)defaultLogger;
- (void)start;
- (void)startWebServer;
- (NSArray *)allRequests;
- (NSArray *)searchRequest:(NSString *)url;

@end
