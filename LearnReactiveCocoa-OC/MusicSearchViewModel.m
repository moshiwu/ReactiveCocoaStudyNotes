//
//  MusicSearchViewModel.m
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/29.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "MusicSearchViewModel.h"

@interface MusicSearchViewModel ()

@end

@implementation MusicSearchViewModel

- (instancetype)init
{
	self = [super init];

	if (self)
	{
		self.searchText = @"";

		RACSignal *signal1 = [[[[RACObserve(self, searchText) filter:^BOOL (NSString *value) {
			return value != nil;
		}] skip:1] throttle:0.5] distinctUntilChanged];

		MyWeakSelf;

		[signal1 subscribeNext:^(id _Nullable x) {
			RACSignal *signal2 = [[NetworkManager sharedManager] music_search:x tag:nil start:0 count:20];

			[signal2 subscribeNext:^(id _Nullable x) {
				NSLog(@"signal2 :%@ ", x);

				if ([x class] == [DouBanSearchResponse class])
				{
					ws.response = (DouBanSearchResponse *)x;
				}
			} error:^(NSError *_Nullable error) {
				NSLog(@"signal error");
			} completed:^{
				NSLog(@"signal2 complete");
			}];
		}];
	}
	return self;
}

- (DouBanSearchResponse *)response
{
	if (_response == nil)
	{
		_response = [DouBanSearchResponse new];
	}
	return _response;
}

@end
