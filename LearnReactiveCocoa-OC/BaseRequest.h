//
//  BaseRequest.h
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"

@interface BaseRequest : NSObject

@property (nonatomic, assign) HttpMethod method;

@property (nonatomic, strong, readonly) NSString *url;

@property (nonatomic, assign) NSTimeInterval timeout;

@property (nonatomic, assign) NSInteger retryCount;

@end
