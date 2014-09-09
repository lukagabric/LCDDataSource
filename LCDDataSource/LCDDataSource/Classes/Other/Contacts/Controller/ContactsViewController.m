#import "ContactsViewController.h"
#import "Contact+CD.h"
#import "ContactDetailsViewController.h"
#import "ContactsDataSource.h"


@implementation ContactsViewController


#pragma mark - Initialize


- (void)initialize
{
    [super initialize];
    
    self.title = @"Contacts";
}


#pragma mark - loadData


- (void)loadData
{
    [super loadData];
    
    __weak typeof(self) weakSelf = self;

    if (_dataSource)
        [_dataSource cancelLoad];
    
    _dataSource = [ContactsDataSource new];
    _dataSource.activityView = self.view;
    _dataSource.saveAfterLoad = YES;
    [_dataSource updateDataWithCompletionBlock:^(NSError *error, BOOL newData) {
        [weakSelf displayData];
    }];
}


#pragma mark - Overridden getters


- (NSString *)entityName
{
    return @"Contact";
}


- (NSArray *)sortKeys
{
    return @[@"lastName", @"firstName"];
}


- (NSString *)mainTableCache
{
    return @"ContactCache";
}


- (BOOL)showIndexes
{
    return YES;
}


- (NSString *)mainTableSectionNameKeyPath
{
    return @"lastNameInitial";
}


- (NSUInteger)fetchBatchSize
{
    return 30;
}


- (NSPredicate *)frcPredicate
{
    return nil;
}


- (NSPredicate *)searchPredicateWithSearchText:(NSString *)searchText scope:(NSInteger)scope
{
    return [NSPredicate predicateWithFormat:@"(lastName CONTAINS[cd] %@) OR (firstName CONTAINS[cd] %@)", searchText, searchText];
}


- (NSUInteger)noOfLettersInSearch
{
    return 3;
}


- (void)configureCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    Contact *contact;
    
    if (tableView == _tableView)
        contact = [_fetchedResultsController objectAtIndexPath:indexPath];
    else
        contact = [_filteredObjects objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", contact.lastName, contact.firstName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", contact.company, contact.email];
}


#pragma mark - Table View Data Source


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactDetailsViewController *details = [ContactDetailsViewController new];
    details.contact = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:details animated:YES];
}


#pragma mark -


@end