//
//  ASIHTTPRequest+L.m
//  LCDDataSource
//
//  Created by Luka Gabric on 23/09/14.
//
//


#import "ASIHTTPRequest+L.h"


@implementation ASIHTTPRequest (L)


- (NSString *)requestEtagOrLastModified
{
    NSDictionary *headers = self.responseHeaders;
    
    NSString *reqId = [headers objectForKey:@"Etag"];
    
    if (!reqId)
        reqId = [headers objectForKey:@"Last-Modified"];
    
    return reqId;
}


@end
