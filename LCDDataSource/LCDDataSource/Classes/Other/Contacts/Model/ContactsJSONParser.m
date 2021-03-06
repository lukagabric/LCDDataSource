//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "ContactsJSONParser.h"
#import "Contact+CD.h"
#import "NSManagedObject+L.h"


@implementation ContactsJSONParser


- (void)bindObject
{
    Contact *contact = [Contact newManagedObjectInContext:_context];
    bindStrJ(contact.firstName, @"firstName");
    bindStrJ(contact.lastName, @"lastName");
    contact.lastNameInitial = [contact.lastName substringToIndex:1];
    bindStrJ(contact.email, @"email");
    bindStrJ(contact.company, @"company");
    [_itemsSet addObject:contact];
}


- (NSString *)rootKeyPath
{
    return @"contacts.contact";
}


@end