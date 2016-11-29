//
//  NetworkManager.h
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HOST	   @"https://api.douban.com/v2"
#define HOST_MUSIC @"https://api.douban.com/v2/music"

typedef void(^NetSuccess)(id value);
typedef void(^NetFailure)(id value);

typedef enum : NSUInteger
{
	HttpMethodGET = 1,
	HttpMethodPost = 2,
} HttpMethod;

@interface NetworkManager : NSObject

+ (instancetype)sharedManager;

- (RACSignal *)music_search:(NSString *)text tag:(NSString *)tag start:(NSInteger)start count:(NSInteger)count;


@end
