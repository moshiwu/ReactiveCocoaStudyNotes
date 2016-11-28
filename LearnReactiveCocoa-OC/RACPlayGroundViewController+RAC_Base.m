//
//  RACPlayGroundViewController+RAC_Base.m
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "RACPlayGroundViewController+RAC_Base.h"

@implementation RACPlayGroundViewController (RAC_Base)

#pragma mark - 基础
- (void)learn_RACSignal_RACSubscriber_RACDisposable
{
	//1.创建信号
	RACSignal *signal = [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > _Nonnull subscriber) {
	    //3.当有订阅者订阅信号的时候，就会调用本block
	    //block会带有一个RACSubscribe对象

	    //4.发送信号
		NSLog(@"signal's subscriber send 1");
		[subscriber sendNext:@"1"];

	    //5.发送完成标记
		[subscriber sendCompleted];

	    //6.RACDisposable，当执行过sendCompleted或者发送失败的时候，里面的block就会调用
		return [RACDisposable disposableWithBlock:^{
			NSLog(@"dispose");
		}];
	}];

	//2.订阅者订阅信号
	[signal subscribeNext:^(id _Nullable x) {
		NSLog(@"signal receive : %@", x);
	}];
}

- (void)learn_RACSubject
{
#pragma mark RACSubject
	// 1.创建信号
	RACSubject *subject = [RACSubject subject];

	//在订阅前发送的话，这个消息是不会被接收到的
	[subject sendNext:@"0"];

	// 2.订阅信号
	[subject subscribeNext:^(id x) {
		NSLog(@"第一个订阅者%@", x);
	}];
	[subject subscribeNext:^(id x) {
		NSLog(@"第二个订阅者%@", x);
	}];
	// 3.发送信号
	[subject sendNext:@"1"];

	//输出
	//第一个订阅者 1
	//第二个订阅者 1
	//第一个订阅者 2
	//第二个订阅者 2

#pragma mark RACReplaySubject
	// 1.创建信号
	RACReplaySubject *replaySubject = [RACReplaySubject subject];

	// 2.发送信号
	[replaySubject sendNext:@1];
	[replaySubject sendNext:@2];

	// 3.订阅信号
	[replaySubject subscribeNext:^(id x) {
		NSLog(@"第一个订阅者接收到的数据 %@", x);
	}];

	// 订阅信号
	[replaySubject subscribeNext:^(id x) {
		NSLog(@"第二个订阅者接收到的数据 %@", x);
	}];

	//注意如果之后再发送信号，就会按订阅者的顺序发送消息
	[replaySubject sendNext:@3];

	//输出
	//第一个订阅者接收到的数据 1
	//第一个订阅者接收到的数据 2
	//第二个订阅者接收到的数据 1
	//第二个订阅者接收到的数据 2
	//第一个订阅者接收到的数据 3    <-- 注意这里后面的顺序变回了“一、二”
	//第二个订阅者接收到的数据 3
}

#pragma mark - RACMulticastConnection
- (void)learn_RACMulticastConnection
{
	//普通方法，因为信号在订阅的时候，会马上执行一次createSignal的block，所以可能会造成问题
	//以下是重复订阅的代码
	RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > _Nonnull subscriber) {
		NSLog(@"send request1");
		[subscriber sendNext:@3333];
		return nil;
	}];

	[signal1 subscribeNext:^(id _Nullable x) {
		NSLog(@"1 %@", x);
	}];

	[signal1 subscribeNext:^(id _Nullable x) {
		NSLog(@"2 %@", x);
	}];

	[signal1 subscribeNext:^(id _Nullable x) {
		NSLog(@"2 %@", x);
	}];

	[signal1 subscribeNext:^(id _Nullable x) {
		NSLog(@"3 %@", x);
	}];

	//send request1
	//1 3333
	//send request1
	//2 3333
	//send request1
	//2 3333
	//send request1
	//3 3333
	//send request2

	//使用RACMulticastConnection，可以避免上述问题
	//原理为RACMulticastConnection内部
	RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > _Nonnull subscriber) {
		NSLog(@"send request2");
		[subscriber sendNext:@9527];
		return nil;
	}];

	//publish里面会创建一个subject
	RACMulticastConnection *connect = [signal2 publish];

	//connect.signal实际上是上面创建的subject，以下的subscribeNext实际上只是这个对象在进行subscribeNext
	[connect.signal subscribeNext:^(id _Nullable x) {
		NSLog(@"1 %@", x);
	}];

	[connect.signal subscribeNext:^(id _Nullable x) {
		NSLog(@"2 %@", x);
	}];

	[connect.signal subscribeNext:^(id _Nullable x) {
		NSLog(@"3 %@", x);
	}];

	[connect.signal subscribeNext:^(id _Nullable x) {
		NSLog(@"4 %@", x);
	}];

	//当执行connect方法时候，subject会让所有的block执行
	[connect connect];

	//send request2
	//1 9527
	//2 9527
	//3 9527
	//4 9527
}

#pragma mark - RACTuple 和 RACSequence
- (void)learn_RAC_RACTuple
{
	//普通创建
	RACTuple *tuple1 = [RACTuple tupleWithObjects:@1, @2, @3, nil];
	RACTuple *tuple2 = [RACTuple tupleWithObjectsFromArray:@[@1, @2, @3]];
	RACTuple *tuple3 = [[RACTuple alloc] init];

	//宏创建
	RACTuple *tuple4 = RACTuplePack(@1, @2, @3, @4);

	//解包(等号前面是参数定义，后面是已存在的Tuple，参数个数需要跟Tuple元素相同）
	RACTupleUnpack(NSNumber * value1, NSNumber * value2, NSNumber * value3, NSNumber * value4) = tuple4;
	NSLog(@"%@ %@ %@ %@", value1, value2, value3, value4);

	//元素访问方式
	NSLog(@"%@", [tuple4 objectAtIndex:1]);
	NSLog(@"%@", tuple4[1]);
}

- (void)learn_RAC_RACSequence
{
	NSArray *array = @[@1, @2, @3, @4];
	NSDictionary *dict = @{@"key1" : @"value1", @"key2" : @"value2", @"key3" : @"value3"};
	NSString *str = @"ABCDEFG";
	NSSet *set = [NSSet setWithArray:array];
	RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:array];

	//NSArray 会返回元素
	[array.rac_sequence.signal subscribeNext:^(id _Nullable x) {
		NSLog(@"array rac_sequence : %@", x);
		NSLog(@"%@", [NSThread currentThread]);
	}];

	for (id obj in dict.rac_sequence)
	{
		NSLog(@"for in %@", obj);
		NSLog(@"%@", [NSThread currentThread]);
	}

	//NSDictionary 会返回打包成Tuple的key、value
	[dict.rac_sequence.signal subscribeNext:^(id _Nullable x) {
		NSLog(@"dict rac_sequence : %@", x);
		NSLog(@"%@", [NSThread currentThread]);
	}];

	//NSString 会返回单个字符
	[str.rac_sequence.signal subscribeNext:^(id _Nullable x) {
		NSLog(@"str rac_sequence : %@", x);
		NSLog(@"%@", [NSThread currentThread]);
	}];

	//NSSet 会返回元素
	[set.rac_sequence.signal subscribeNext:^(id _Nullable x) {
		NSLog(@"set rac_sequence : %@", x);
	}];

	//RACTuple 会返回内置数组的元素
	[tuple.rac_sequence.signal subscribeNext:^(id _Nullable x) {
		NSLog(@"tuple rac_sequence : %@", x);
		NSLog(@"%@", [NSThread currentThread]);
	}];
}

#pragma mark - RAC 常用宏
- (void)learn_RAC_Macro
{
	//1.RAC(TARGET, ...)
	//用来给某个对象的某个属性绑定信号，只要信号产生内容，就会把内容给属性赋值
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 264, 200, 40)];

	label.backgroundColor = [UIColor yellowColor];
	[self.view addSubview:label];

	UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0, 364, 200, 40)];
	tf.backgroundColor = [UIColor greenColor];
	[self.view addSubview:tf];

	RAC(label, text) = tf.rac_textSignal;

	//2.RACObserve(TARGET, KEYPATH)
	//普通观察者写法
	RACSignal *frameSignal1 = [self rac_valuesForKeyPath:@"view.frame" observer:nil];
	//直接用宏的写法
	RACSignal *frameSignal2 = RACObserve(self.view, frame);

	//3.@strongify(obj) 和 @weakify(obj) 配套使用解决循环引用
	//过程略

	//4.RACTuplePack和RACTupleUnpack 打包和解包
	RACTuple *tuple = RACTuplePack(@1, @2);
	RACTupleUnpack(NSNumber * value1, NSNumber * value2) = tuple;
	NSLog(@"%@ %@", value1, value2);
}

@end
