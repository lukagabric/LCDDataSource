//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "ASIHTTPRequest.h"


@protocol LCDParserInterface <NSObject>


- (void)parseData:(NSData *)data;
- (NSError *)error;
- (NSSet *)itemsSet;
- (void)abortParsing;
- (void)setContext:(NSManagedObjectContext *)context;


@end