//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "ASIHTTPRequest.h"


@protocol LCDParserInterface <NSObject>


- (void)parseData:(NSData *)data;
- (void)setUserInfo:(id)userInfo;
- (void)setASIHTTPRequest:(ASIHTTPRequest *)request;
- (NSError *)getError;
- (NSSet *)getItemsSet;
- (void)abortParsing;
- (void)setContext:(NSManagedObjectContext *)context;


@end