//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LAbstractCDJSONParser.h"


@implementation LAbstractCDJSONParser


#pragma mark - init


- (id)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}


- (void)initialize
{
    _dateTimeFormatter = [NSDateFormatter new];
    _dateTimeFormatter.dateFormat = [self getDateTimeFormat];
    
    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.dateFormat = [self getDateFormat];
}


#pragma mark - Parser data


- (void)parseData:(id)data
{
	if (data)
	{
		_itemsSet = [NSMutableSet new];
        
        id jsonObject = nil;
        
        if ([data isKindOfClass:[NSData class]])
        {
            NSError *error = nil;
            
            jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            _error = error;
        }
        else
        {
            jsonObject = data;
        }
        
        if (jsonObject)
        {
            _rootJsonObject = jsonObject;
            
            NSString *rootKeyPath = [self getRootKeyPath];
            
            if (rootKeyPath)
                _rootJsonObject = [jsonObject valueForKeyPath:rootKeyPath];
            
            if (_rootJsonObject)
            {
                if ([_rootJsonObject isKindOfClass:[NSDictionary class]])
                {
                    _currentElement = _rootJsonObject;
                    [self bindObject];
                }
                else if ([_rootJsonObject isKindOfClass:[NSArray class]])
                {
                    for (id item in _rootJsonObject)
                    {
                        if ([item isKindOfClass:[NSDictionary class]])
                        {
                            _currentElement = item;
                            [self bindObject];
                        }
                    }
                }
            }
        }
	}
	else
	{
		_error = [NSError errorWithDomain:@"No data" code:0 userInfo:nil];
	}
}


#pragma mark - Bind object


- (void)bindObject
{
    
}


#pragma mark - Setters


- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
}


- (void)setUserInfo:(id)userInfo
{
    _userInfo = userInfo;
}


- (void)setASIHTTPRequest:(ASIHTTPRequest *)request
{
    _request = request;
}


#pragma mark - Getters


- (NSString *)getDateFormat
{
    return @"yyyy-MM-dd";
}


- (NSString *)getDateTimeFormat
{
    return @"yyyy-MM-dd hh:mm:ss Z";
}


- (NSSet *)getItemsSet
{
	return [NSSet setWithSet:_itemsSet];
}


- (NSError *)getError
{
    return _error;
}


- (NSString *)getRootKeyPath
{
    return nil;
}


#pragma mark - abort


- (void)abortParsing
{
	_error = [NSError errorWithDomain:@"Parsing aborted." code:299 userInfo:nil];
}


#pragma mark -


@end