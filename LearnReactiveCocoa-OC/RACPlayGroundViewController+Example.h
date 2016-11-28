//
//  RACPlayGroundViewController+Example.h
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "RACPlayGroundViewController.h"

@protocol ProgrammerDelegate
- (void)makeAnApp;
@end

@interface RACPlayGroundViewController (Example)


#pragma mark - 1. 观察值变化
- (void)example1;

#pragma mark - 2. 单边响应
- (void)example2;

#pragma mark - 3. 双边响应
- (void)example3;

#pragma mark - 4. 代理 Delegate
- (void)example4;

#pragma mark - 5. 广播 NSNotificationCenter
- (void)example5;

#pragma mark - 6. 串联 concat
- (void)example6;

#pragma mark - 7. 并联 merge
- (void)example7;

#pragma mark - 8. 组合 combineLatest
- (void)example8;

#pragma mark - 9. 合流压缩 zipWith
- (void)example9;

#pragma mark - 10. 映射 map
- (void)example10;

#pragma mark - 11. filter 过滤
- (void)example11;

#pragma mark - 12. 秩序 flattenMap
- (void)example12;

#pragma mark - 13. 命令 Command
- (void)example13;

#pragma mark - 14. 延迟 delay
- (void)example14;

#pragma mark - 15. 重放 replay
- (void)example15;

#pragma mark - 16. 定时 interval
- (void)example16;

#pragma mark - 17. 超时 timeout
- (void)example17;

#pragma mark - 18. 重试 retry
- (void)example18;

#pragma mark - 19. 节流 throttle
- (void)example19;

#pragma mark - 20. 条件 takeUntil
- (void)example20;
@end
