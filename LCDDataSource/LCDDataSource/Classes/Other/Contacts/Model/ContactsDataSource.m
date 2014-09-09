#import "ContactsDataSource.h"
#import "ContactsParser.h"
#import "ContactsJSONParser.h"


@implementation ContactsDataSource


#define JSON 1


- (ASIHTTPRequest *)contactRequest
{
#if JSON
    return [LAbstractStackedRequestsSource stackedRequestWithUrl:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.json"
                                                 timeoutInterval:5
                                                         headers:nil
                                                      parameters:nil
                                                   requestMethod:@"GET"
                                                             key:@"ContactsJSON"
                                                     parserClass:[ContactsJSONParser class]];
#else
    return [LAbstractStackedRequestsSource stackedRequestWithUrl:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.xml"
                                                 timeoutInterval:5
                                                         headers:nil
                                                      parameters:nil
                                                   requestMethod:@"GET"
                                                             key:@"Contacts"
                                                     parserClass:[ContactsParser class]];
#endif
}


- (NSArray *)stackedRequests
{
    return @[[self contactRequest]];
}


@end