//
//  ViewController+RAC_Group.m
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/17.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "RACPlayGroundViewController+RAC_Group.h"
#import "ReactiveObjC.h"
#import "RACReturnSignal.h"

@implementation RACPlayGroundViewController (RAC_Group)

#pragma mark - RAC bind（group的实现基础）
- (void)learn_RAC_bind
{
	RACSubject *subject1 = [RACSubject subject];
	//	__block RACSubject *subject2 = [RACSubject subject];
//
	RACSignal *bindSignal = [subject1 bind:^ RACStreamBindBlock _Nonnull{
		return ^RACStream *(id value, BOOL *stop) {
			NSLog(@"bind block");

			return [RACReturnSignal return :value];
		};
	}];
    

	[bindSignal subscribeNext:^(id _Nullable x) {
		NSLog(@"bind signal receive : %@", x);
	}];

	[subject1 sendNext:@"sign"];
}

#pragma mark - RAC group
- (void)learn_RAC_group_concat
{
	RACSignal *signalA = [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > _Nonnull subscriber) {
		[subscriber sendNext:@"signal A message"];
		[subscriber sendCompleted];
		return nil;
	}];

	RACSignal *signalB = [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > _Nonnull subscriber) {
		[subscriber sendNext:@"signal B message"];
		[subscriber sendCompleted];
		return nil;
	}];

	RACSignal *signalC = [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > _Nonnull subscriber) {
		[subscriber sendNext:@"signal C message"];
	    //		[subscriber sendCompleted];
		return nil;
	}];

	//concat 连接，顺序执行
	//当前一个信号sendCompleted的时候，下一个信号才会发送
	//A->B->C
	//	RACSignal *concatSignal1 = [[signalA concat:signalB] concat:signalC];
	RACSignal *concatSignal1 = [RACSignal concat:@[signalA, signalB, signalC]]; //其他RAC Group方法一样可以用类方法连接

	[concatSignal1 subscribeNext:^(id _Nullable x) {
		NSLog(@"concat signal 1 receive : %@", x);
	}];

	//A->B
	RACSignal *concatSignal2 = [signalA concat:signalB];

	[concatSignal2 subscribeNext:^(id _Nullable x) {
		NSLog(@"concat signal 2 receive : %@", x);
	}];
}

- (void)learn_RAC_group_then
{
	RACSignal *signalA = [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > _Nonnull subscriber) {
		[subscriber sendNext:@"signal A message"];
		[subscriber sendCompleted];
		return nil;
	}];

	RACSignal *signalB = [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > _Nonnull subscriber) {
		[subscriber sendNext:@"signal B message"];
		[subscriber sendCompleted];
		return nil;
	}];

	RACSignal *signalC = [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > _Nonnull subscriber) {
		[subscriber sendNext:@"signal C message"];
	    //		[subscriber sendCompleted];
		return nil;
	}];

	//then 类似concat，当第一个信号完成，才会连接then返回的信号，但会忽略第一个信号
	//example 1
	RACSignal *thenSignal1 = [signalA then:^RACSignal *_Nonnull {
	    //A被忽略了
		return [signalB then:^RACSignal *_Nonnull {
	        //B也被忽略了
			return signalC;
		}];
	}];

	[thenSignal1 subscribeNext:^(id _Nullable x) {
		NSLog(@"then signal 1 receive : %@", x);
	}];

	//example 2
	RACSignal *thenSignal2 = [signalA then:^RACSignal *_Nonnull {
	    //A被忽略
		return signalB;
	}];

	[signalA subscribeNext:^(id _Nullable x) {
		NSLog(@"这是被忽略的A信号 %@", x);
	}];

	[thenSignal2 subscribeNext:^(id _Nullable x) {
		NSLog(@"then signal 2 receive : %@", x);
	}];
}

- (void)learn_RAC_group_merge
{
	RACSubject *signalA = [RACSubject subject];
	RACSubject *signalB = [RACSubject subject];
	RACSubject *signalC = [RACSubject subject];

	//merge
	//就是把几个信号整合成一个信号，只需要订阅整合的信号，就能接收到信号源发送的信息
	RACSignal *mergeSignal = [[signalA merge:signalB] merge:signalC];

	[mergeSignal subscribeNext:^(id _Nullable x) {
		NSLog(@"merge signal receive : %@", x);
	}];

	[signalB sendNext:@"signal B"];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[signalC sendNext:@"signal C"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[signalA sendNext:@"signal A"];
	});
}

- (void)learn_RAC_group_zipWith
{
	RACSubject *signalNumber = [RACSubject subject];
	RACSubject *signalCharactor = [RACSubject subject];

	//zipWith
	//把信号打包成一个RACTuple
	//zip后收到的信号，总是会一组一组的显示（可以理解为两段数据流中，第一组的信号总要等到第二组收到"同一位置"的信号，才会打包信号发给zip signal）
	//
	//  -----------1-------2-------3----------4-------------------->  signalNumber
	//  -----A---------------------B-------------------C----------->  signalCharactor
	//  -----------A1--------------B2------------------C3---------->  zipSignal
	//
	RACSignal *zipSignal = [signalNumber zipWith:signalCharactor];

	[zipSignal subscribeNext:^(id _Nullable x) {
		NSLog(@"zip signal receive : %@", x);
		NSLog(@"---------------我真的不是分割线---------------------");
	}];

	NSLog(@"signalCharactor 发送 A");
	[signalCharactor sendNext:@"A"];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalNumber 发送 1");
		[signalNumber sendNext:@"1"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalNumber 发送 2");
		[signalNumber sendNext:@"2"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalNumber 发送 3");
		[signalNumber sendNext:@"3"];

		NSLog(@"signalCharactor 发送 B");
		[signalCharactor sendNext:@"B"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalNumber 发送 4");
		[signalNumber sendNext:@"4"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalCharactor 发送 C");
		[signalCharactor sendNext:@"C"];
	});
}

- (void)learn_RAC_group_combineLatestWith
{
	RACSubject *signalNumber = [RACSubject subject];
	RACSubject *signalCharactor = [RACSubject subject];

	//combineLatestWith
	//把信号打包成一个RACTuple
	//和zip类似，但两组信号只会保留各自最新的信号，旧的信号会被替换（实际上不一定是替换，但是可以这样理解）
	//
	//  -----------1-------2-------3----------4-------------------->  signalNumber
	//  -----A---------------------B-------------------C----------->  signalCharactor
	//  -----------A1------A2------B3---------B4-------C4---------->  combineLatestSignal
	//
	RACSignal *combineLatestSignal = [signalNumber combineLatestWith:signalCharactor];

	[combineLatestSignal subscribeNext:^(id _Nullable x) {
		NSLog(@"combineLatestSignal receive : %@", x);
		NSLog(@"---------------我真的不是分割线---------------------");
	}];

	NSLog(@"signalCharactor 发送 A");
	[signalCharactor sendNext:@"A"];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalNumber 发送 1");
		[signalNumber sendNext:@"1"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalNumber 发送 2");
		[signalNumber sendNext:@"2"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalNumber 发送 3");
		[signalNumber sendNext:@"3"];

		NSLog(@"signalCharactor 发送 B");
		[signalCharactor sendNext:@"B"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalNumber 发送 4");
		[signalNumber sendNext:@"4"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalCharactor 发送 C");
		[signalCharactor sendNext:@"C"];
	});
}

- (void)learn_RAC_group_reduce
{
	RACSubject *signalNumber = [RACSubject subject];
	RACSubject *signalCharactor = [RACSubject subject];

	//reduce
	//自己合并信号，reduce的block里面的参数个数是由自己控制，跟数组里面的对应
	RACSignal *combineLatestSignal = [RACSignal combineLatest:@[signalNumber, signalCharactor] reduce:^id (NSString *num, NSString *str) {
		return [str stringByAppendingString:num];
	}];

	[combineLatestSignal subscribeNext:^(id _Nullable x) {
		NSLog(@"combineLatestSignal receive : %@", x);
		NSLog(@"---------------我真的不是分割线---------------------");
	}];

	NSLog(@"signalCharactor 发送 A");
	[signalCharactor sendNext:@"A"];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalNumber 发送 1");
		[signalNumber sendNext:@"1"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalNumber 发送 2");
		[signalNumber sendNext:@"2"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalNumber 发送 3");
		[signalNumber sendNext:@"3"];

		NSLog(@"signalCharactor 发送 B");
		[signalCharactor sendNext:@"B"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalNumber 发送 4");
		[signalNumber sendNext:@"4"];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"signalCharactor 发送 C");
		[signalCharactor sendNext:@"C"];
	});
}

@end
