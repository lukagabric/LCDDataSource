//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LCDParserInterface.h"


#define ifIsNull(key)                ([[_currentElement objectForKey:key] isKindOfClass:[NSNull class]])
#define bindStrJ(obj, key)    obj = ifIsNull(key) ? nil : [_currentElement objectForKey:key]
#define bindIntJ(obj, key)    obj = ifIsNull(key) ? 0 : [[_currentElement objectForKey:key] intValue]
#define bindFloatJ(obj, key)  obj = ifIsNull(key) ? 0 : [[_currentElement objectForKey:key] floatValue]
#define bindNumberToStringJ(obj, key)  obj = ifIsNull(key) ? nil : [[_currentElement objectForKey:key] stringValue]
#define bindDateJ(obj, key)   obj = ifIsNull(key) ? nil : [_dateFormatter dateFromString:[_currentElement objectForKey:key]]
#define bindDateTimeJ(obj, key)   obj = ifIsNull(key) ? nil : [_dateTimeFormatter dateFromString:[_currentElement objectForKey:key]]
#define bindUrlFromDict(obj, key)	   obj = (!ifIsNull(key) && [_currentElement objectForKey:key] != nil) ? [NSURL URLWithString:[_currentElement objectForKey:key]] : nil;
#define bindBoolFromDict(obj, key)   obj = ifIsNull(key) ? NO : [[_currentElement objectForKey:key] boolValue]


@interface LAbstractCDJSONParser : NSObject <LCDParserInterface>
{
    NSManagedObjectContext *_context;
    NSMutableSet *_itemsSet;

    NSDateFormatter *_dateTimeFormatter;
    NSDateFormatter *_dateFormatter;
    
    id _rootJsonObject;
    NSDictionary *_currentElement;
    
    NSError *_error;
    id _userInfo;
    ASIHTTPRequest *_request;
}


@end


#pragma mark - Protected


@interface LAbstractCDJSONParser ()


- (void)initialize;

- (void)bindObject;

- (NSString *)getDateTimeFormat;
- (NSString *)getDateFormat;
- (NSString *)getRootKeyPath;


@end