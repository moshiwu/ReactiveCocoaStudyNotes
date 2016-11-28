//
//  RACPlayGroundViewController+Example.m
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "RACPlayGroundViewController+Example.h"
#import "ReactiveObjC.h"
#import "RACReturnSignal.h"

@interface RACPlayGroundViewController () <ProgrammerDelegate>

@end

@implementation RACPlayGroundViewController (Example)


#pragma mark - 1. 观察值变化
- (void)example1
{
//    你别动，你一动我就知道。
	//当self.value的值变化时调用Block，这是用KVO的机制，RAC封装了KVO
	@weakify(self);
	[RACObserve(self, value) subscribeNext:^(NSString *x) {
		@strongify(self);
		NSLog(@"你动了 %ld", self.value);
	}];

	self.value = 1;
	self.value = 2;
}


#pragma mark - 2. 单边响应
- (void)example2
{
    //你唱歌，我就跳舞。
	//创建一个信号

	RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
	    //这个信号里面有一个Next事件的玻璃球和一个Complete事件的玻璃球
		[subscriber sendNext:@"唱歌"];
		[subscriber sendCompleted];
		return nil;
	}];

	//对信号进行改进，当信号里面流的是”唱歌”，就改成”跳舞”返还给self.value
	RAC(self, value) = [signalA map:^id (NSString *value) {
		if ([value isEqualToString:@"唱歌"])
		{
			return @"跳舞";
		}
		return @"";
	}];
}

#pragma mark - 3. 双边响应
- (void)example3
{
//    你向西，他就向东，他向左，你就向右。
	//创建2个通道，一个从A流出的通道A和一个从B流出的通道B
	RACChannelTerminal *channelA = RACChannelTo(self, valueA);
	RACChannelTerminal *channelB = RACChannelTo(self, valueB);

	//改造通道A，使通过通道A的值，如果等于"西"，就改为"东"传出去
	[[channelA map:^id (NSString *value) {
		if ([value isEqualToString:@"西"])
		{
			return @"东";
		}
		return value;
	}] subscribe:channelB]; //通道A流向B
	//改造通道B，使通过通道B的值，如果等于"左"，就改为"右"传出去
	[[channelB map:^id (NSString *value) {
		if ([value isEqualToString:@"左"])
		{
			return @"右";
		}
		return value;
	}] subscribe:channelA]; //通道B流向A
	//KVO监听valueA的值得改变，过滤valueA的值，返回YES表示通过
	[[RACObserve(self, valueA) filter:^BOOL (id value) {
		return value ? YES : NO;
	}] subscribeNext:^(NSString *x) {
		NSLog(@"你向%@", x);
	}];
	//KVO监听valueB的值得改变，过滤valueB的值，返回YES表示通过
	[[RACObserve(self, valueB) filter:^BOOL (id value) {
		return value ? YES : NO;
	}] subscribeNext:^(NSString *x) {
		NSLog(@"他向%@", x);
	}];
	//下面使valueA的值和valueB的值发生改变
	self.valueA = @"西";
	self.valueB = @"左";
}

#pragma mark - 4. 代理 Delegate
- (void)example4
{
//    你是程序员，你帮我写个app吧。
	//代理定义
//    @protocol ProgrammerDelegate
//    - (void)makeAnApp;
//    @end

	/****************************************/
	//为self添加一个信号，表示代理ProgrammerDelegate的makeAnApp方法信号
	RACSignal *programmerSignal = [self rac_signalForSelector:@selector(makeAnApp)
												 fromProtocol:@protocol(ProgrammerDelegate)];

	//设置代理方法makeAnApp的实现
	[programmerSignal subscribeNext:^(RACTuple *x) {
	    //这里可以理解为makeAnApp的方法要的执行代码
		NSLog(@"花了一个月，app写好了");
	}];
	//调用代理方法
	[self makeAnApp];
}

#pragma mark -  5. 广播 NSNotificationCenter
- (void)example5
{
//    知道你的频道，我就能听到你了。
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	//注册广播通知
	RACSignal *signal = [center rac_addObserverForName:@"代码之道频道" object:nil];

	//设置接收到通知的回调处理
	[signal subscribeNext:^(NSNotification *x) {
		NSLog(@"技巧：%@", x.userInfo[@"技巧"]);
	}];
	//发送广播通知
	[center postNotificationName:@"代码之道频道"
						  object:nil
						userInfo:@{@"技巧" : @"用心写"}];
}


#pragma mark - 6. 串联 concat
- (void)example6
{
//    两个管串联，一个管处理完自己的东西，下一个管才开始处理自己的东西
//    生活是一个故事接一个故事。

	//创建一个信号管A
	RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
	    //发送一个Next玻璃球和一个Complete玻璃球
		[subscriber sendNext:@"我恋爱啦"];
		[subscriber sendCompleted];
		return nil;
	}];
	//创建一个信号管B
	RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id subscriber) {
	    //发送一个Next玻璃球和一个Complete玻璃球
		[subscriber sendNext:@"我结婚啦"];
		[subscriber sendCompleted];
		return nil;
	}];
	//串联管A和管B
	RACSignal *concatSignal = [signalA concat:signalB];

	//串联后的接收端处理
	[concatSignal subscribeNext:^(id x) {
		NSLog(@"%@", x);
	}];
	//打印：我恋爱啦 我结婚啦
}


#pragma mark - 7. 并联 merge
- (void)example7
{
//    两个管并联，只要有一个管有东西，就拿出来处理它。
//    污水都应该流入污水处理厂被处理。

	//创建信号A
	RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
		[subscriber sendNext:@"纸厂污水"];
		return nil;
	}];
	//创建信号B
	RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id subscriber) {
		[subscriber sendNext:@"电镀厂污水"];
		return nil;
	}];
	//并联2个信号
	RACSignal *mergeSignal = [RACSignal merge:@[signalA, signalB]];

	[mergeSignal subscribeNext:^(id x) {
		NSLog(@"处理%@", x);
	}];
}
#pragma mark - 8. 组合 combineLatest
- (void)example8
{
    //你是红的，我是黄的，我们就是红黄的，你是白的，我没变，我们是白黄的...反正只要最新的
    
	//定义2个自定义信号
	RACSubject *letters = [RACSubject subject];
	RACSubject *numbers = [RACSubject subject];

	//组合信号
	[[RACSignal combineLatest:@[letters, numbers]
					   reduce:^(NSString *letter, NSString *number) {
	    //把2个信号的信号值进行字符串拼接
		return [letter stringByAppendingString:number];
	}] subscribeNext:^(NSString *x) {
		NSLog(@"%@", x);
	}];
	//自己控制发送信号值
	[letters sendNext:@"绿"];
	[letters sendNext:@"红"];
	[numbers sendNext:@"黄"]; //打印红黄
	[letters sendNext:@"白"]; //打印白黄
	[numbers sendNext:@"青"]; //打印青黄
}
#pragma mark - 9. 合流压缩 zipWith
- (void)example9
{
    //你是红的，我是黄的，我们就是红黄的，你是白的，我没变，哦，那就等我变了再说吧...反正我们只要一对的
    
	//创建信号A
	RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
		[subscriber sendNext:@"红"];
		[subscriber sendNext:@"白"];
		return nil;
	}];
	//创建信号B
	RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id subscriber) {
		[subscriber sendNext:@"黄"];
		return nil;
	}];

	//合流后出来的是压缩包，需要解压才能取到里面的值
	[[signalA zipWith:signalB] subscribeNext:^(RACTuple *x) {
	    //解压缩
		RACTupleUnpack(NSString * stringA, NSString * stringB) = x;
		NSLog(@"我们是%@%@的", stringA, stringB);
	}];
	//打印：我们是红黄的
}
#pragma mark - 10. 映射 map
- (void)example10
{
    //我可以点石成金。（信号内容变化）
	//创建信号，发送"石"玻璃球
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
		[subscriber sendNext:@"石"];
		return nil;
	}];

	//对信号进行改造，改造"石"为"金"
	signal = [signal map:^id (NSString *value) {
		if ([value isEqualToString:@"石"])
		{
			return @"金";
		}
		return value;
	}];
	//打印
	[signal subscribeNext:^(id x) {
		NSLog(@"%@", x); //金
	}];
}
#pragma mark - 11. filter 过滤
- (void)example11
{
//    11. 过滤
//    未满十八岁，禁止进入。
	//创建信号
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
		[subscriber sendNext:@(15)];
		[subscriber sendNext:@(17)];
		[subscriber sendNext:@(21)];
		[subscriber sendNext:@(14)];
		[subscriber sendNext:@(30)];
		return nil;
	}];

	//过滤信号，并打印
	[[signal filter:^BOOL (NSNumber *value) {
	    //值大于等于18的才能通过过滤网
		return value.integerValue >= 18;
	}] subscribeNext:^(id x) {
		NSLog(@"%@", x);
	}];
	//打印：21 30
}

#pragma mark - 12. 秩序 flattenMap
- (void)example12
{
    //打蛋液，煎鸡蛋，上盘。（每一步都变了信号）
	//创建一个信号
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
		NSLog(@"打蛋液");
		[subscriber sendNext:@"蛋液"];
		[subscriber sendCompleted];
		return nil;
	}];

	//对信号进行秩序执行第一步
	signal = [signal flattenMap:^RACStream *(NSString *value) {
	    //处理上一步的RACSignal的信号值value，这里value = @"蛋液"
		NSLog(@"把%@倒进锅里面煎", value);
	    //返回下一步的RACSignal信号
		return [RACSignal createSignal:^RACDisposable *(id subscriber) {
			[subscriber sendNext:@"煎蛋"];
			[subscriber sendCompleted];
			return nil;
		}];
	}];
	//对信号进行秩序执行第二步
	signal = [signal flattenMap:^RACStream *(NSString *value) {
	    //处理上一步的RACSignal的信号值value，这里value = @"煎蛋"
		NSLog(@"把%@装到盘里", value);
	    //返回下一步的RACSignal信号
		return [RACSignal createSignal:^RACDisposable *(id subscriber) {
			[subscriber sendNext:@"上菜"];
			[subscriber sendCompleted];
			return nil;
		}];
	}];
	//最后打印
	[signal subscribeNext:^(id x) {
		NSLog(@"%@", x);
	}];

	/*
	 *  打印：
	 *  打蛋液
	 *  把蛋液倒进锅里面煎
	 *  把煎蛋装到盘里
	 *  上菜
	 */
}

#pragma mark - 13. 命令 Command
- (void)example13
{
//    我命令你马上投降。
	//创建命令
	RACCommand *aCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *input) {
	    //命令执行代码
		NSLog(@"%@我投降了", input);
	    //返回一个RACSignal信号
		return [RACSignal createSignal:^RACDisposable *(id subscriber) {
			[subscriber sendCompleted];
			return nil;
		}];
	}];

	//执行命令
	[aCommand execute:@"今天"];
	//打印：今天我投降了
}

#pragma mark - 14. 延迟 delay
- (void)example14
{
//    等等我，我还有10秒钟就到了。
	//创建一个信号
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
		NSLog(@"等等我，我还有10秒钟就到了");
		[subscriber sendNext:@"车陂南"];
		[subscriber sendCompleted];
		return nil;
	}];

	//延时10秒接受Next玻璃球
	[[signal delay:10] subscribeNext:^(NSString *x) {
		NSLog(@"我到了%@", x);
	}];

	/*
	 *  [2016-04-21 13:20:10]等等我，我还有10秒钟就到了
	 *  [2016-04-21 13:20:20]我到了车陂南
	 */
}

#pragma mark - 15. 重放 replay
- (void)example15
{
//    一次制作，多次观看。
	//创建一个普通信号
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
		NSLog(@"大导演拍了一部电影《我的男票是程序员》");
		[subscriber sendNext:@"《我的男票是程序员》"];
		return nil;
	}];
	//创建该普通信号的重复信号
	RACSignal *replaySignal = [signal replay];

	//重复接受信号
	[replaySignal subscribeNext:^(NSString *x) {
		NSLog(@"小明看了%@", x);
	}];
	[replaySignal subscribeNext:^(NSString *x) {
		NSLog(@"小红也看了%@", x);
	}];

	/*
	 *  大导演拍了一部电影《我的男票是程序员》
	 *  小明看了《我的男票是程序员》
	 *  小红也看了《我的男票是程序员》
	 */
}

#pragma mark - 16. 定时 interval
- (void)example16
{
//    每隔8个小时服一次药。
	//创建定时器信号，定时8个小时
	RACSignal *signal = [RACSignal interval:60 * 60 * 8
								onScheduler  :[RACScheduler mainThreadScheduler]];

	//定时执行代码
	[signal subscribeNext:^(id x) {
		NSLog(@"吃药");
	}];
}

#pragma mark - 17. 超时 timeout
- (void)example17
{
//    等了你一个小时了，你还没来，我走了。
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
	    //创建发送信息信号
		NSLog(@"我快到了");
		RACSignal *sendSignal = [RACSignal createSignal:^RACDisposable *(id sendSubscriber) {
			[sendSubscriber sendNext:nil];
			[sendSubscriber sendCompleted];
			return nil;
		}];
	    //发送信息要1个小时10分钟才到
		[[sendSignal delay:60 * 70] subscribeNext:^(id x) {
	        //这里才发送Next玻璃球到signal
			[subscriber sendNext:@"我到了"];
			[subscriber sendCompleted];
		}];
		return nil;
	}];

	//这里对signal进行超时接受处理，如果1个小时都没收到玻璃球，超时错误

	[[signal timeout:60 * 60 onScheduler:[RACScheduler mainThreadScheduler]] subscribeError:^(NSError *error)
	{
	    //超时错误处理
		NSLog(@"等了你一个小时了，你还没来，我走了");
	}];
}

#pragma mark - 18. 重试 retry
- (void)example18
{
//    18. 重试
//    成功之前可能需要数百次失败。
	__block int failedCount = 0;
	//创建信号
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
		if (failedCount < 100)
		{
			failedCount++;
			NSLog(@"我失败了");
	        //发送错误，才会要重试
			[subscriber sendError:nil];
		}
		else
		{
			NSLog(@"经历了数百次失败后");
			[subscriber sendNext:nil];
		}
		return nil;
	}];
	//重试
	RACSignal *retrySignal = [signal retry];

	//直到发送了Next玻璃球
	[retrySignal subscribeNext:^(id x) {
		NSLog(@"终于成功了");
	}];
}

#pragma mark - 19. 节流 throttle
- (void)example19
{
//    19. 节流
//    不好意思，这里一秒钟只能通过一个人。
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
	    //即时发送一个Next玻璃球
		[subscriber sendNext:@"旅客A"];
	    //下面是GCD延时发送Next玻璃球
		dispatch_queue_t mainQueue = dispatch_get_main_queue();
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), mainQueue, ^{
			[subscriber sendNext:@"旅客B"];
		});
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), mainQueue, ^{
			//发送多个Next，如果节流了，接收最新发送的
			[subscriber sendNext:@"旅客C"];
			[subscriber sendNext:@"旅客D"];
			[subscriber sendNext:@"旅客E"];
		});
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), mainQueue, ^{
			[subscriber sendNext:@"旅客F"];
		});
		return nil;
	}];

	//对信号进行节流，限制短时间内一次只能接收一个Next玻璃球
	[[signal throttle:1] subscribeNext:^(id x) {
		NSLog(@"%@通过了", x);
	}];

	/*
	 *  [2015-08-16 22:08:45.677]旅客A
	 *  [2015-08-16 22:08:46.737]旅客B
	 *  [2015-08-16 22:08:47.822]旅客E
	 *  [2015-08-16 22:08:48.920]旅客F
	 */
}

#pragma mark - 20. 条件 takeUntil
- (void)example20
{
//    20. 条件（takeUntil方法：当给定的signal完成前一直取值）
//    直到世界的尽头才能把我们分开。
	//创建取值信号
	RACSignal *takeSignal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
	    //创建一个定时器信号，每隔1秒触发一次
		RACSignal *signal = [RACSignal interval:0.1 onScheduler:[RACScheduler mainThreadScheduler]];
	    //定时接收
		[signal subscribeNext:^(id x) {
	        //在这里定时发送Next玻璃球
			[subscriber sendNext:@"直到世界的尽头才能把我们分开"];
		}];
		return nil;
	}];
	//创建条件信号
	RACSignal *conditionSignal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
	    //设置5秒后发生Complete玻璃球
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
		(int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			NSLog(@"世界的尽头到了");
			[subscriber sendCompleted];
		});
		return nil;
	}];

	//设置条件，takeSignal信号在conditionSignal信号接收完成前，不断地取值
	[[takeSignal takeUntil:conditionSignal] subscribeNext:^(id x) {
		NSLog(@"%@", x);
	}];
    
	/*
	 *  [2015-08-16 22:17:22.648]直到世界的尽头才能把我们分开
	 *  [2015-08-16 22:17:23.648]直到世界的尽头才能把我们分开
	 *  [2015-08-16 22:17:24.645]直到世界的尽头才能把我们分开
	 *  [2015-08-16 22:17:25.648]直到世界的尽头才能把我们分开
	 *  [2015-08-16 22:17:26.644]直到世界的尽头才能把我们分开
	 *  [2015-08-16 22:17:26.645]世界的尽头到了
	 */
}

@end
