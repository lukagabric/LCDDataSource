#import "ContactDetailsViewController.h"


@implementation ContactDetailsViewController


#pragma mark - Initialize


- (void)initialize
{
    [super initialize];
    
    self.title = @"Contact details";
}


#pragma mark - bindGUI


- (void)bindGUI
{
    [super bindGUI];
    
    _labelFirstName.text = _contact.firstName;
    _labelLastName.text = _contact.lastName;
    _labelEmail.text = _contact.email;
    _labelCompany.text = _contact.company;
}


#pragma mark - Setters


- (void)setContact:(Contact *)contact
{
    _contact = contact;
    
    if ([self isViewLoaded])
        [self bindGUI];
}


#pragma mark -


@end