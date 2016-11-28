//
//  RACPlayGroundViewController+RACCommand.m
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "RACPlayGroundViewController+RACCommand.h"

@implementation RACPlayGroundViewController (RACCommand)


#pragma mark - RACCommand和switchToLatest
- (void)learn_RACCommand
{
    
    // 一、RACCommand使用步骤:
    // 1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
    // 2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
    // 3.执行命令 - (RACSignal *)execute:(id)input
    
    // 二、RACCommand使用注意:
    // 1.signalBlock必须要返回一个信号，不能传nil.
    // 2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
    // 3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
    
    // 三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
    // 1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
    // 2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。
    
    // 四、如何拿到RACCommand中返回信号发出的数据。
    // 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
    // 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
    
    // 五、监听当前命令是否正在执行executing
    
    // 六、使用场景,监听按钮点击，网络请求
    
    //以下只是简单的实现方法，并不一定是网络请求的实际做法
    typedef enum : NSUInteger
    {
        NetworkCommandLogin = 1001,
        NetworkCommandRegister = 1002,
        NetworkCommandLogout = 1003,
    } NetworkCommand;
    
    //1.创建command
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * (NSNumber *inputCommand) {
        
        //实际应用的时候，这里写上网络请求，返回该网络请求对应的信号
        //这样说会比较好理解：网络请求完成时候，信号sendCompleted或者sendError，然后RACCommand的订阅者收到该信号，执行后续操作
        switch (inputCommand.unsignedIntegerValue)
        {
            case NetworkCommandLogin:
            {
                return [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > subscriber) {
                    NSLog(@"这是登录信号的block");
                    [subscriber sendNext:@"登录"];
                    [subscriber sendCompleted];
                    return nil;
                }];
            }
                break;
                
            case NetworkCommandRegister:
            {
                return [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > subscriber) {
                    NSLog(@"这是注册信号的block");
                    [subscriber sendNext:@"注册"];
                    [subscriber sendCompleted];
                    return nil;
                }];
            }
                
                break;
                
            case NetworkCommandLogout:
            {
                return [RACSignal createSignal:^RACDisposable *_Nullable (id < RACSubscriber > subscriber) {
                    NSLog(@"这是注销信号的block（模拟失败）");
                    [subscriber sendError:nil]; //这里模拟失败
                    return nil;
                }];
            }
                
                break;
                
            default:
                return [RACSignal empty];
                
                break;
        }
    }];
    
    //这个属性设为YES的话，就能多任务同时执行，
    //command.allowsConcurrentExecution = YES;
    
    //3.使用excuting来监听command进度
    [[command.executing skip:1] subscribeNext:^(NSNumber *_Nullable x) {
        if (x.boolValue)
        {
            NSLog(@"命令正在执行...");
        }
        else
        {
            NSLog(@"命令已经完成");
            NSLog(@"-------------");
        }
    }];
    
    //4.订阅RACCommand中的信号（信号源）
    //4.1普通方式获取信号源
    [command.executionSignals subscribeNext:^(id x) {
        [x subscribeNext:^(id x) {
            NSLog(@"普通方式获取的信号 收到信号 %@", x);
        }];
    }];
    
    //4.2使用switchToLatest获取信号源
    [command.executionSignals.switchToLatest subscribeNext:^(id _Nullable x) {
        NSLog(@"switchToLatest获取的信号 收到信号 %@", x);
    }];
    
    
    //5.使用errors来订阅失败的讯号
    [command.errors subscribeNext:^(NSError *_Nullable x) {
        NSLog(@"command receive error : %@", x);
    }];
    
    //6.执行命令
    [command execute:@(NetworkCommandLogin)]; //execute会返回一个RACSignal对象
    
    //如果直接execute下一个命令，会报错："The command is disabled and cannot be executed"
    [command execute:@(NetworkCommandLogin)];
    [command execute:@(NetworkCommandLogin)];
    [command execute:@(NetworkCommandLogin)];
    
    //直接看是看不到的，需要获取execute的RACSignal对象，订阅失败信息才能看到
    RACSignal *failSignal = [command execute:@(NetworkCommandLogin)];
    [failSignal subscribeError:^(NSError * _Nullable error) {
        NSLog(@"错误信号：%@", error);
    }];
    
    //上一个命令需要等待下一个命令执行完毕，如果加一点延时，就能正确显示
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [command execute:@(NetworkCommandLogout)];
    });
    
    
    
}

- (void)learn_switchToLast
{
    RACSubject *signalOfSignals = [RACSubject subject];
    
    signalOfSignals.name = @"sign all";
    
    RACSubject *signalA = [RACSubject subject];
    signalA.name = @"sign A";
    RACSubject *signalB = [RACSubject subject];
    signalB.name = @"sign B";
    
    NSLog(@"switchToLatest : %@", signalOfSignals.switchToLatest);
    
    //以下方法可以帮助理解switchToLatest，原理大体上相同，但少了撤销之前信号的步骤
    //	[signalOfSignals subscribeNext:^(RACSubject *x) {
    //		NSLog(@"接受到信号 %@", x);
    //
    //      //这里应该有一个撤销原来信号的步骤，但现在不会，应该是用subscribeNext返回的RACDisposable
    //
    //		[x subscribeNext:^(id _Nullable x) {
    //			NSLog(@"里信号接受到信号 %@", x);
    //		}];
    //	}];
    
    //switchToLatest
    //可理解为切换到最近的信号源
    //虽然为切换，但打印出来的name还是"sign all"，并不是以下例子的"sign A","sign B"
    //具体这点可查看源代码，但学习的时候并不理解
    [signalOfSignals.switchToLatest subscribeNext:^(id _Nullable x) {
        NSLog(@"接收到信号 %@", x);
    }];
    
    //1.切换到signal A
    [signalOfSignals sendNext:signalA];
    [signalA sendNext:@"AAA111"];                                  //打印AAA111
    [signalB sendNext:@"BBB111"];                                  //不打印
    NSLog(@"switchToLatest : %@", signalOfSignals.switchToLatest); //打印sign name : sign all
    
    //2.切换到signal B
    [signalOfSignals sendNext:signalB];
    [signalA sendNext:@"AAA222"];                                  //不打印
    [signalB sendNext:@"BBB222"];                                  //打印BBB222
    NSLog(@"switchToLatest : %@", signalOfSignals.switchToLatest); //打印sign name : sign all
    
    //3.又切换到signal A
    [signalOfSignals sendNext:signalA];
    [signalA sendNext:@"AAA333"];                                  //打印AAA333
    [signalB sendNext:@"BBB333"];                                  //不打印
    NSLog(@"switchToLatest : %@", signalOfSignals.switchToLatest); //打印sign name : sign all
}


@end
