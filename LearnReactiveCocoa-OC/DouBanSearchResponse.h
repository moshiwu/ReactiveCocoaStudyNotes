//
//  DouBanSearchResponse.h
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "BaseResponse.h"

@class DouBanSearchResponseSubMusicRating;
@class DouBanSearchResponseSubMusic;

@interface DouBanSearchResponse : BaseResponse

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger total;

@property (nonatomic, strong) NSMutableArray *musics;

@end

@interface DouBanSearchResponseSubMusic : NSObject

@property (nonatomic, strong) DouBanSearchResponseSubMusicRating *rating;
@property (nonatomic, strong) NSArray *anthor;
@property (nonatomic, strong) NSString *alt_title;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSString *mobile_link;
@property (nonatomic, strong) NSDictionary *attrs;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *alt;
@property (nonatomic, assign) NSInteger id;

@end


@interface DouBanSearchResponseSubMusicRating: NSObject

@property (nonatomic, assign) NSInteger max;
@property (nonatomic, assign) NSInteger min;
@property (nonatomic, assign) CGFloat average;
@property (nonatomic, assign) NSInteger numRaters;

@end
