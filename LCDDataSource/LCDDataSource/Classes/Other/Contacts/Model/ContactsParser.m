#import "ContactsParser.h"
#import "Contact+CD.h"
#import "NSManagedObject+L.h"


@implementation ContactsParser
{
    Contact *_contact;
}


- (void)didStartElement
{
    ifElement(@"contact") _contact = [Contact newManagedObjectInContext:_context];
}


- (void)didEndElement
{
    ifElement(@"contact") [_itemsSet addObject:_contact];
    elifElement(@"firstName") bindStr(_contact.firstName);
    elifElement(@"lastName")
    {
        bindStr(_contact.lastName);
        _contact.lastNameInitial = [_contact.lastName substringToIndex:1];
    }
    elifElement(@"email") bindStr(_contact.email);
    elifElement(@"company") bindStr(_contact.company);
}


@end