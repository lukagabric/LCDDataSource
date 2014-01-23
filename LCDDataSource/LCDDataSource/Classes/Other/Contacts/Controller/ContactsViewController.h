#import "LAbstractCDViewController.h"
#import "ContactsDataSource.h"


@interface ContactsViewController : LAbstractCDViewController
{
    ContactsDataSource *_dataSource;
}


@end