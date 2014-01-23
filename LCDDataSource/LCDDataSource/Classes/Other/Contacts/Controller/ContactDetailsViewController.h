#import "LAbstractViewController.h"
#import "Contact+CD.h"


@interface ContactDetailsViewController : LAbstractViewController
{
    __weak IBOutlet UILabel *_labelFirstName;
    __weak IBOutlet UILabel *_labelLastName;
    __weak IBOutlet UILabel *_labelEmail;
    __weak IBOutlet UILabel *_labelCompany;
}


@property (strong, nonatomic) Contact *contact;


@end