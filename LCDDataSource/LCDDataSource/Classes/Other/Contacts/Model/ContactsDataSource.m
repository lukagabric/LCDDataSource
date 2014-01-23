#import "ContactsDataSource.h"
#import "ContactsParser.h"


@implementation ContactsDataSource


- (ASIHTTPRequest *)contactRequest
{
    return [LAbstractASICDDataSource stackedRequestWithUrl:@"https://dl.dropboxusercontent.com/u/18883987/lions/contacts1.xml"
                                           timeoutInterval:5
                                                   headers:nil
                                                parameters:nil
                                             requestMethod:@"GET"
                                                       key:@"Contacts"
                                               parserClass:[ContactsParser class]];
}


- (NSArray *)stackedRequests
{
    return @[[self contactRequest]];
}


@end