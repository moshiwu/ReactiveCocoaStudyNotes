//
//  MusicSearchViewModel.h
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/29.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#import "DouBanSearchResponse.h"
#import "DouBanSearchRequest.h"

@interface MusicSearchViewModel : NSObject

@property (nonatomic, strong) NSString *searchText;

@property (nonatomic, strong) DouBanSearchResponse *response;

@property (nonatomic, strong) RACCommand *command;

@end
