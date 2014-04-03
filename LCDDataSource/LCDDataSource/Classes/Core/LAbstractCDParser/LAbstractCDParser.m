//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LAbstractCDParser.h"


@implementation LAbstractCDParser
{
	NSMutableString *_mElementValue;
}


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


#pragma mark - Parse data


- (void)parseData:(NSData *)data
{
	if (data && !_parser && !_error)
	{
		_parser = [[NSXMLParser alloc] initWithData:data];

		_itemsSet = [NSMutableSet new];

		[_parser setDelegate:self];

		[_parser setShouldProcessNamespaces:NO];
		[_parser setShouldReportNamespacePrefixes:NO];
		[_parser setShouldResolveExternalEntities:NO];

		[_parser parse];
	}
	else
	{
		_error = [NSError errorWithDomain:@"No data" code:0 userInfo:nil];
	}
}


#pragma mark - NSXMLParserDelegate


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (string != nil)
	{
		[_mElementValue appendString:string];
	}
	else
	{
		_error = [NSError errorWithDomain:@"Parsing error! Appending nil value." code:-1 userInfo:nil];
		NSLog(@"Parsing error! Appending nil value.");
		[parser abortParsing];
	}
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	_error = parseError;
	NSLog(@"%@", [NSString stringWithFormat:@"Parsing error code %i, %@, at line: %i, column: %i", [parseError code], [[parser parserError] localizedDescription], [parser lineNumber], [parser columnNumber]]);
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	_mElementValue = [[NSMutableString alloc] init];
	_elementValue = nil;
	_elementName = [NSString stringWithString:elementName];
	_attributesDict = attributeDict;

	[self didStartElement];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	_elementName = [NSString stringWithString:elementName];
	_elementValue = [[NSString stringWithString:_mElementValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	[self didEndElement];
}


- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	_mElementValue = [[NSMutableString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
}


#pragma mark - Methods to override in subclass


- (void)didStartElement
{
    
}


- (void)didEndElement
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
    return @"yyyy-MM-dd hh:mm:ss";
}


- (NSSet *)getItemsSet
{
	return [NSSet setWithSet:_itemsSet];
}


- (NSError *)getError
{
    return _error;
}


#pragma mark - abort


- (void)abortParsing
{
    [_parser setDelegate:nil];
	[_parser abortParsing];
    _parser = nil;
	_error = [NSError errorWithDomain:@"Parsing aborted." code:299 userInfo:nil];
}


#pragma mark -


@end