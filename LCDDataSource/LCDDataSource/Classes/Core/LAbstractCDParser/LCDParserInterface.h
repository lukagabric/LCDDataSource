//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//



@protocol LGCDParserInterface <NSObject>


- (void)parseData:(NSData *)data;
- (void)setResponse:(NSURLResponse *)response;
- (NSError *)error;
- (NSSet *)itemsSet;
- (void)abortParsing;
- (void)setContext:(NSManagedObjectContext *)context;


@end