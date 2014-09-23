#import "DataSourceFactory.h"
#import "ContactsParser.h"
#import "ContactsJSONParser.h"


@implementation DataSourceFactory


#define JSON 1


+ (ASIHTTPRequest *)contactRequest
{
#if JSON
    return [LDataUpdateOperationManager stackedRequestWithUrl:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.json"
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


+ (LDataUpdateOperationManager *)contactsDataManagerWithActivityView:(UIView *)activityView
{
    LDataUpdateOperationManager *contactsDataManager = [[LDataUpdateOperationManager alloc] initWithStackedRequests:@[[self contactRequest]] andGroupId:@"contacts"];
    contactsDataManager.activityView = activityView;
    
    return contactsDataManager;
}


@end