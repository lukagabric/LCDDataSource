#import "HomeViewController.h"
#import "ContactsViewController.h"


@implementation HomeViewController


#pragma mark - Actions


- (IBAction)buttonAction:(id)sender
{
    if (sender == _buttonContacts)
    {
        [self.navigationController pushViewController:[ContactsViewController new] animated:YES];
    }
}


#pragma mark -


@end