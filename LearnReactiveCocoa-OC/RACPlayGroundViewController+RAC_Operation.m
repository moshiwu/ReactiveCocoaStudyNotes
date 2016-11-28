//
//  ViewController+RAC_Operation.m
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/21.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "RACPlayGroundViewController+RAC_Operation.h"
#import "ReactiveObjC.h"
#import "RACReturnSignal.h"

@implementation RACPlayGroundViewController (RAC_Operation)

#pragma mark - Operations
- (void)learn_RAC_operation_filter
{
	//过滤，很容易理解
	RACSubject *filterSignal = [RACSubject subject];

	[[filterSignal filter:^BOOL (NSString *value) {
		return value.length > 3;
	}] subscribeNext:^(id _Nullable x) {
		NSLog(@"收到信号：%@", x);
	}];

	[filterSignal sendNext:@"1"];
	[filterSignal sendNext:@"12"];
	[filterSignal sendNext:@"123"];
	[filterSignal sendNext:@"1234"];
	[filterSignal sendNext:@"12345"];
	[filterSignal sendNext:@"123456"];
	[filterSignal sendNext:@"1234567"];
}

- (void)learn_RAC_operation_ignore
{
	//原信号
	RACSubject *originSignal = [RACSubject subject];

	//ignore后变成新信号
	RACSignal *ignoreSignal = [originSignal ignore:@"123"];

	//ignoreValue表示忽略所有值，所有值都不会接收
//    RACSignal *ignoreAllSignal = [originSignal ignoreValues];

	//订阅的信号为新信号
	[ignoreSignal subscribeNext:^(id _Nullable x) {
		NSLog(@"receive : %@", x);
	}];

	//发送消息的还是旧信号
	[originSignal sendNext:@"1"];
	[originSignal sendNext:@"12"];
	[originSignal sendNext:@"123"];
	[originSignal sendNext:@"1234"];
	[originSignal sendNext:@"12345"];
	[originSignal sendNext:@"123456"];
	[originSignal sendNext:@"1234567"];
}

- (void)learn_RAC_operation_take
{
	//take      ：取前面第N个信号，之后的信号均被忽略

	__block RACSubject *subject = [RACSubject subject];

	[[subject take:1] subscribeNext:^(id _Nullable x) {
		NSLog(@"take signal receive : %@", x);
	}];

	[subject sendNext:@"signal 1"];
	[subject sendNext:@"signal 2"];
	[subject sendNext:@"signal 3"];
	[subject sendNext:@"signal 4"];
	[subject sendNext:@"signal 5"];
}

- (void)learn_RAC_operation_takeLast
{
	//takeLast  ：取后面第N个信号，订阅者必须调用完成才能收到信号，因为只有完成才知道总共有几个信号

	__block RACSubject *subject = [RACSubject subject];

	[[subject takeLast:2] subscribeNext:^(id _Nullable x) {
		NSLog(@"take last signal receive : %@", x);
	}];

	//takeLast使用的时候要注意流程，并不是send以后马上被订阅者接收到（因为要等待sendCompleted）
	for (int i = 0; i < 5; i++)
	{
		NSString *signalString = [NSString stringWithFormat:@"signal %d", i];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[subject sendNext:signalString];
			NSLog(@"send %@", signalString);

			if (i == 5 - 1)
			{
				[subject sendCompleted];
			}
		});
	}
}

- (void)learn_RAC_operation_takeUntil
{
	//takeUntil ：原信号A跟另一信号B绑定，如果B发送任何信号，则A信号不再接收信息
	RACSubject *subject = [RACSubject subject];

	RACSubject *completeSignal = [RACSubject subject];

	//注意：[subject takeUntil:completeSignal]实际上已经产生了新的RACSignal，订阅信息的是这个新的RACSignal
	[[subject takeUntil:completeSignal] subscribeNext:^(id _Nullable x) {
		NSLog(@"take until receivce : %@", x);
	}];

	for (int i = 0; i < 10; i++)
	{
		NSString *signalString = [NSString stringWithFormat:@"signal %d", i];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[subject sendNext:signalString];
			NSLog(@"send %@", signalString);

			if (i == 3)
			{
				NSLog(@"completeSignal send completed");
				[completeSignal sendCompleted];
			}
		});
	}
}

- (void)learn_RAC_operation_distinctUntilChange
{
	//distinctUntilChange: 如果当前发送的信号跟上次发送的信号值相同，则不会被订阅者接收到
	RACSubject *subject = [RACSubject subject];

	[[subject distinctUntilChanged] subscribeNext:^(id _Nullable x) {
		NSLog(@"skip signal receivce : %@", x);
	}];

	for (int i = 0; i < 10; i++)
	{
		NSString *signalString = [NSString stringWithFormat:@"signal %d，%@", i, i < 5 ? @"smaller then 5" : @"bigger or equal then 5"];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[subject sendNext:i < 5 ? @(101) : @(102)];
			NSLog(@"send %@", signalString);
		});
	}
}

- (void)learn_RAC_operation_skip
{
	//distinctUntilChange: 如果当前发送的信号跟上次发送的信号值相同，则不会被订阅者接收到
	RACSubject *subject = [RACSubject subject];

	[[subject skip:2] subscribeNext:^(id _Nullable x) {
		NSLog(@"distinct change receivce : %@", x);
	}];

	for (int i = 0; i < 10; i++)
	{
		NSString *signalString = [NSString stringWithFormat:@"signal %d", i];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[subject sendNext:signalString];
			NSLog(@"send %@", signalString);
		});
	}
}

- (void)learn_RAC_map_and_flattenMap
{
	//map
	RACSubject *mapOriginSignal = [RACSubject subject];

	RACSignal *mapSignal = [mapOriginSignal map:^id (id value) {
	    //		value = [value stringByAppendingString:@" with map"];
	    //      return [RACReturnSignal return:value];
	    //map中的block返回的是id对象
		return [value stringByAppendingString:@" with map"];
	}];

	[mapSignal subscribeNext:^(id _Nullable x) {
		NSLog(@"mapSignal receive : %@", x);
	}];

	[mapOriginSignal sendNext:@"111"];

	//flattenMap
	RACSubject *originSignal = [RACSubject subject];

	RACSignal *flattenSignal = [originSignal flattenMap:^__kindof RACStream *(NSString *value) {
	    //flattenMap中的block要求返回的是RACStream对象
		value = [value stringByAppendingString:@" with flatten"];
		return [RACReturnSignal return :value];
	}];

	[flattenSignal subscribeNext:^(id _Nullable x) {
		NSLog(@"flattenSignal receive : %@", x);
	}];

	[originSignal sendNext:@"333"];

	//flattenMap使用场景
	//TODO:学习的时候不知道用意
	RACSubject *signalOfSignals = [RACSubject subject];
	signalOfSignals.name = @"sign all";

	RACSubject *signalA = [RACSubject subject];
	signalA.name = @"sign A";

	//对比1
	//    NSLog(@"switchToLatest : %@", signalOfSignals.switchToLatest);
	//    [signalOfSignals.switchToLatest subscribeNext:^(id _Nullable x) {
	//        NSLog(@"接收到信号 %@", x);
	//    }];

	//对比2
	[[signalOfSignals flattenMap:^RACStream *(id value) {
		return value;
	}] subscribeNext:^(id _Nullable x) {
		NSLog(@"signalOfSignals receive : %@", x);
	}];

	[signalOfSignals sendNext:signalA];
	[signalA sendNext:@"AAA111"];
}

@end
