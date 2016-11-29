//
//  DouBanSearchRequest.m
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "DouBanSearchRequest.h"

@implementation DouBanSearchRequest

- (NSString *)url
{
	return [NSString stringWithFormat:@"%@/search", HOST_MUSIC];
}

@end
