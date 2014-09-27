#import "LGAbstractCDViewController.h"
#import "DataSourceFactory.h"
#import "LGDataUpdateOperationManager.h"


@interface ContactsViewController : LGAbstractCDViewController
{
    LGDataUpdateOperationManager *_contactsDataManager;
}


@end