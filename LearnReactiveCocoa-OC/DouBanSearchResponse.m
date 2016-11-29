//
//  DouBanSearchResponse.m
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "DouBanSearchResponse.h"

@implementation DouBanSearchResponseSubMusicRating


@end

@implementation DouBanSearchResponseSubMusic

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{@"rating" : [DouBanSearchResponseSubMusicRating class]  };
}


@end

@implementation DouBanSearchResponse

+ (NSDictionary *)modelContainerPropertyGenericClass
{
	return @{@"musics" : [DouBanSearchResponseSubMusic class]};
}

@end

