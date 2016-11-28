//
//  ViewController.m
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/11.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "RACPlayGroundViewController.h"
#import "ReactiveObjC.h"
#import "RACReturnSignal.h"
#import "RACPlayGroundViewController+RAC_Group.h"
#import "RACPlayGroundViewController+RAC_Operation.h"
#import "RACPlayGroundViewController+RAC_Base.h"
#import "RACPlayGroundViewController+RACCommand.h"
#import "RACPlayGroundViewController+Example.h"
#import "RACSubscriber.h"

@interface RACPlayGroundViewController ()

@end

@implementation RACPlayGroundViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	//基础
//	[self learn_RACSignal_RACSubscriber_RACDisposable];
//	[self learn_RACSubject];
//	[self learn_RACMulticastConnection];

	//宏
//	[self learn_RAC_Macro];

	//集合
//	[self learn_RAC_RACTuple];
//	[self learn_RAC_RACSequence];

	//命令
//	[self learn_switchToLast];
//	[self learn_RACCommand];

	//组合
//	[self learn_RAC_bind];
//	[self learn_RAC_group_concat];
//	[self learn_RAC_group_then];
//	[self learn_RAC_group_merge];
//	[self learn_RAC_group_zipWith];
//	[self learn_RAC_group_combineLatestWith];
//	[self learn_RAC_group_reduce];

	//核心操作方法 Operations
//	[self learn_RAC_operation_filter];
//	[self learn_RAC_operation_ignore];
//	[self learn_RAC_operation_take];
//	[self learn_RAC_operation_takeLast];
//	[self learn_RAC_operation_takeUntil];
//	[self learn_RAC_operation_distinctUntilChange];
//	[self learn_RAC_operation_skip];
//	[self learn_RAC_map_and_flattenMap];

	//20例
//	[self example1];  //观察值变化
//	[self example2];  //单边响应
//	[self example3];  //双边响应
//	[self example4];  //代理 Delegate
//	[self example5];  //广播 NSNotificationCenter
//	[self example6];  //串联 concat
//	[self example7];  //并联 merge
//	[self example8];  //组合 combineLatest
//	[self example9];  //合流压缩 zipWith
//	[self example10]; //映射 map
//	[self example11]; //过滤 filter
//	[self example12]; //秩序 flattenMap
//	[self example13]; //命令 command
//	[self example14]; //延迟 delay
//	[self example15]; //重放 replay
//	[self example16]; //定时 interval
//	[self example17]; //超时 timeout
//	[self example18]; //重试 retry
//	[self example19]; //节流 throttle
	[self example20]; //条件 takeUntil
}

@end
