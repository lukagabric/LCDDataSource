#import "DataSourceFactory.h"
#import "ContactsParser.h"
#import "ContactsJSONParser.h"


@implementation DataSourceFactory


#define JSON 0


#if JSON
+ (LDataUpdateOperation *)contactsUpdateOperation
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.json"]];
    return [[LDataUpdateOperation alloc] initWithSession:[NSURLSession sharedSession]
                                                 request:request
                                       requestIdentifier:@"ContactsJSON"
                                               andParser:[ContactsJSONParser new]];
}

#else

+ (LDataUpdateOperation *)contactsUpdateOperation
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.xml"]];
    return [[LDataUpdateOperation alloc] initWithSession:[NSURLSession sharedSession]
                                                 request:request
                                       requestIdentifier:@"ContactsXML"
                                               andParser:[ContactsParser new]];
}
#endif


+ (LDataUpdateOperationManager *)contactsDataManagerWithActivityView:(UIView *)activityView
{
    LDataUpdateOperationManager *contactsDataManager = [[LDataUpdateOperationManager alloc] initWithUpdateOperations:@[[self contactsUpdateOperation]] andGroupId:@"contacts"];
    contactsDataManager.activityView = activityView;
    
    return contactsDataManager;
}


@end