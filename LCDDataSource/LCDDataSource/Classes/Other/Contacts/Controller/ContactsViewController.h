#import "LAbstractCDViewController.h"
#import "DataSourceFactory.h"
#import "LDataUpdateOperationManager.h"


@interface ContactsViewController : LAbstractCDViewController
{
    LDataUpdateOperationManager *_contactsDataManager;
}


@end