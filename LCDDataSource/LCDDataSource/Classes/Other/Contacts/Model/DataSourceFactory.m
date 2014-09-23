#import "DataSourceFactory.h"
#import "ContactsParser.h"
#import "ContactsJSONParser.h"


@implementation DataSourceFactory


#define JSON 0


+ (ASIHTTPRequest *)contactRequest
{
#if JSON
    return [LDataUpdateOperationManager stackedRequestWithUrl:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.json"
                                                 timeoutInterval:5
                                                         headers:nil
                                                      parameters:nil
                                                   requestMethod:@"GET"
                                                             key:@"ContactsJSON"];
#else
    return [LDataUpdateOperationManager stackedRequestWithUrl:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.xml"
                                              timeoutInterval:5
                                                      headers:nil
                                                   parameters:nil
                                                requestMethod:@"GET"
                                                          key:@"Contacts"];
#endif
}


- (id)contactsParser
{
#if JSON
    return [ContactsJSONParser new];
#else
    return [ContactsParser new];
#endif
}


+ (LDataUpdateOperation *)contactsUpdateOperation
{
    return [[LDataUpdateOperation alloc] initWithRequest:[self contactRequest] andParser:[ContactsParser new]];
}


+ (LDataUpdateOperationManager *)contactsDataManagerWithActivityView:(UIView *)activityView
{
    LDataUpdateOperationManager *contactsDataManager = [[LDataUpdateOperationManager alloc] initWithUpdateOperations:@[[self contactsUpdateOperation]] andGroupId:@"contacts"];
    contactsDataManager.activityView = activityView;
    
    return contactsDataManager;
}


@end