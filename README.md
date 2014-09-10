LCDDataSource
=============

LCDDataSource is used to simplify the process of getting remote data and storing it using Core Data framework. The model uses a Root context for async data persistance (saving data in background so main thread is not blocked). Main context is used on the main thread - presenting data to the user (UI). Worker contexts are used by the data sources and parsers for asynchronous data fetching and parsing. There is only one Root and one Main context, but multiple Worker contexts - one for each data source. Contexts are in a parent-child relationships: Root->Main->Worker(s). Any Worker context may be easily merged into Main context or discarded at all times without disturbing the main context.

ASIHTTPRequest is used for data download.

LAbstractCDParser
-----------------

Abstract parser implements core parsing methods and allows to start binding data right away. The methods below are called on element start/end and data collected is stored in member variables. There are convenient macros used to bind data quickly, including binding strings, numbers, dates, primitives etc. Child context of main context is used to store parsed data before it is merged and saved into the main context.

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
    
LCoreDataController
-------------------

Singleton that controls managed object contexts (root and main), object model and store coordinator.

LAbstractCDViewController
-------------------------

Table view controller that uses NSFetchedResultsController to fetch data.

NSManagedObject and NSManagedObjectContext
------------------------------------------

Class extensions with helper methods for managed object and managed object context manipulation.

