//
//  DouBanSearchRequest.h
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "BaseRequest.h"

@interface DouBanSearchRequest : BaseRequest

@property (nonatomic, strong) NSString *q;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger count;

@end
