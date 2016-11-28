//
//  ViewController+RAC_Group.h
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/17.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "RACPlayGroundViewController.h"

@interface RACPlayGroundViewController (RAC_Group)

#pragma mark - RAC bind（group的实现基础）
- (void)learn_RAC_bind;

#pragma mark - RAC group
- (void)learn_RAC_group_concat;

- (void)learn_RAC_group_then;

- (void)learn_RAC_group_merge;

- (void)learn_RAC_group_zipWith;

- (void)learn_RAC_group_combineLatestWith;

- (void)learn_RAC_group_reduce;
@end
