#import "ContactsDataSource.h"
#import "ContactsParser.h"


@implementation ContactsDataSource


- (ASIHTTPRequest *)contactRequest
{
    return [LAbstractASICDDataSource stackedRequestWithUrl:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.xml"
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