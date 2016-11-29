//
//  NSArray+MyLog.m
//
//  Created by 莫锹文 on 15/11/12.
//  Copyright © 2015年 莫锹文. All rights reserved.
//

#import "NSArray+MyLog.h"

@implementation NSArray (Log)

- (NSString *)descriptionWithLocale:(id)locale
{
	NSMutableString *str = [NSMutableString stringWithFormat:@"%ld (\n", self.count];

	for (id obj in self)
	{
		[str appendFormat:@"\t%@, \n", obj];
	}

	[str appendString:@")"];

	return str;
}

- (NSString *)jsonString
{
	NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];

	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
