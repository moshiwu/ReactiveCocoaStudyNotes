//
//  BaseRequest.m
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "BaseRequest.h"
#import "NetworkManager.h"
@implementation BaseRequest

- (instancetype)init
{
	self = [super init];

	if (self)
	{
		self.method = HttpMethodGET;
        self.retryCount = 0;
        self.timeout = 0;
	}
	return self;
}

- (NSString *)url
{
	return HOST;
}

@end
