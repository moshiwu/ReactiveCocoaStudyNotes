//
//  NetworkManager.m
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "NetworkManager.h"
#import "DouBanSearchRequest.h"
#import "DouBanSearchResponse.h"

@implementation NetworkManager

+ (instancetype)sharedManager
{
	static NetworkManager *instance = nil;

	if (instance == nil)
	{
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			instance = [[NetworkManager alloc] init];
		});
	}

	return instance;
}

- (RACSignal *)music_search:(NSString *)text tag:(NSString *)tag start:(NSInteger)start count:(NSInteger)count
{
	DouBanSearchRequest *request = [[DouBanSearchRequest alloc] init];

	request.q = text;
	request.tag = tag;
	request.start = start;
	request.count = count;

	return [[self request:request] map:^id (id value) {
		if ([value isKindOfClass:[NSDictionary class]])
		{
			DouBanSearchResponse *model = [DouBanSearchResponse modelWithDictionary:value];
			return model;
		}
		else
		{
			return value;
		}
	}];
}

- (RACSignal *)request:(BaseRequest *)request
{
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > _Nonnull subscriber) {
    
		switch (request.method)
		{
			case HttpMethodGET:
				{
					[self GET:request withSubscriber:subscriber];
				}
				break;

			case HttpMethodPost:
				{
					[self POST:request withSubscriber:subscriber];
				}

			default:
				break;
		}

		return nil;
	}];

	if (request.timeout > 0)
	{
		signal = [signal timeout:request.timeout onScheduler:[RACScheduler schedulerWithPriority:RACSchedulerPriorityDefault]];
	}

	if (request.retryCount > 0)
	{
		signal = [signal retry:request.retryCount];
	}

	return signal;
}

- (void)GET:(BaseRequest *)request withSubscriber:(id <RACSubscriber>)subscriber
{
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

	NSLog(@"send GET request : [%@] [%@]", request.url, request.modelToJSONString);

	[manager GET:request.url
	  parameters:request.modelToJSONObject
		progress:^(NSProgress *_Nonnull downloadProgress) {
		[subscriber sendNext:downloadProgress];
	}
		 success:^(NSURLSessionDataTask *_Nonnull task, NSDictionary *responseObject) {
		[subscriber sendNext:responseObject];
		[subscriber sendCompleted];
	}
		 failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
		NSLog(@"failure : %@", error);
		[subscriber sendError:error];
	}
	];
}

- (void)POST:(BaseRequest *)request withSubscriber:(id <RACSubscriber>)subscriber
{
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

	NSLog(@"send POST request : [%@] [%@]", request.url, request.modelToJSONString);

	[manager POST:request.url
	   parameters:request.modelToJSONObject
		 progress:^(NSProgress *_Nonnull downloadProgress) {
		[subscriber sendNext:downloadProgress];
	}
		  success:^(NSURLSessionDataTask *_Nonnull task, NSDictionary *responseObject) {
		[subscriber sendNext:responseObject];
		[subscriber sendCompleted];
	}
		  failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
		NSLog(@"failure : %@", error);
		[subscriber sendError:error];
	}
	];
}

@end
