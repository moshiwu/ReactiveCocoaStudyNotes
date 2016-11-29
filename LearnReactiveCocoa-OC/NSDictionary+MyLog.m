//
//  NSDictionary+MyLog.m
//
//  Created by 莫锹文 on 15/11/12.
//  Copyright © 2015年 莫锹文. All rights reserved.
//

#import "NSDictionary+MyLog.h"

@implementation NSDictionary (MyLog)

- (NSString *)descriptionWithLocale:(id)locale
{
	NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"{\t\n "];

	for (NSString *key in self) {
		id value = self[key];
		[str appendFormat:@"\t \"%@\" = %@,\n", key, value];
	}

	[str appendString:@"}"];

	return str;
}

- (NSString *)jsonString
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


@end
