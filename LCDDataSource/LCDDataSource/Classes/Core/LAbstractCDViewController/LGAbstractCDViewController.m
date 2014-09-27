//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGAbstractCDViewController.h"
#import "LGCoreDataController.h"


@implementation LGAbstractCDViewController


#pragma mark - Synthesize


@synthesize fetchedResultsController = _fetchedResultsController;


#pragma mark - View


- (void)viewDidUnload
{
    _fetchedResultsController = nil;
    
    [super viewDidUnload];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:YES];
}


#pragma mark - bindGUI


- (void)bindGUI
{
    [super bindGUI];
    
    [self displayData];
}


#pragma mark - Cleanup


- (void)cleanup
{
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
    _filteredObjects = nil;
    _filteredResults = nil;
    
    [_tableView reloadData];
}


#pragma mark - Display data


- (void)displayData
{
    _filteredResults = [NSMutableDictionary new];

    [NSFetchedResultsController deleteCacheWithName:[self mainTableCache]];
    
    NSError *error = nil;
    
    if ([self.fetchedResultsController performFetch:&error])
    {
        [_tableView reloadData];
    }
    else
    {
        NSLog(@"%@", error);
        abort();
    }
}


#pragma mark - Getters


- (NSString *)entityName
{
    return nil;
}


- (NSArray *)sortDescriptors
{
    return nil;
}


- (NSArray *)sortKeys
{
    return nil;
}


- (NSString *)mainTableSectionNameKeyPath
{
    return nil;
}


- (NSString *)mainTableCache
{
    return nil;
}


- (NSPredicate *)frcPredicate
{
    return nil;
}


- (NSPredicate *)searchPredicateWithSearchText:(NSString *)searchText scope:(NSInteger)scope
{
    return nil;
}


- (NSUInteger)noOfLettersInSearch
{
    return 0;
}


- (BOOL)showIndexes
{
    return NO;
}


- (NSUInteger)fetchBatchSize
{
    return 30;
}


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController) return _fetchedResultsController;
    
    //delete cache
    [NSFetchedResultsController deleteCacheWithName:[self mainTableCache]];
    
    //request
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    //entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:mainMOC()];
    [fetchRequest setEntity:entity];
    
    //predicate
    NSPredicate *predicate = [self frcPredicate];
    if (predicate)
        [fetchRequest setPredicate:predicate];
    
    //sort descriptors
    NSArray *sortDescriptors = [self sortDescriptors];
    
    if (!sortDescriptors || [sortDescriptors count] == 0)
    {
        NSArray *sortKeys = [self sortKeys];
        
        if (sortKeys && [sortKeys count] > 0)
        {
            NSMutableArray *descriptors = [NSMutableArray new];
            
            for (NSString *key in sortKeys)
            {
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
                [descriptors addObject:sortDescriptor];
            }
            
            sortDescriptors = [NSArray arrayWithArray:descriptors];
        }
    }
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //batch size
    [fetchRequest setFetchBatchSize:[self fetchBatchSize]];
    
    //fetched results controller
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:mainMOC()
                                                                      sectionNameKeyPath:[self mainTableSectionNameKeyPath]
                                                                               cacheName:[self mainTableCache]];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


#pragma mark - Search display


- (void)searchTableViewWillShow
{
    
}


- (void)searchTableViewDidHide
{

}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tableView == _tableView ? [[_fetchedResultsController sections] count] : 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView)
    {
        id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else
    {
        return [_filteredObjects count];
    }
}


- (void)configureCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    [self configureCell:cell forTableView:tableView atIndexPath:indexPath];
    
    return cell;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView != _tableView)
        return nil;

    if (![self showIndexes])
        return nil;
    
    return [_fetchedResultsController sectionIndexTitles];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView != _tableView)
        return nil;
    
    NSArray *sections = [_fetchedResultsController sections];
    
    if (sections.count <= section)
        return nil;
    
    return [[sections objectAtIndex:section] name];
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[_fetchedResultsController sectionIndexTitles] indexOfObject:title];
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Content Filtering


- (void)filterContentForSearchText:(NSString *)searchText scope:(NSInteger)scope
{
    if ([searchText length] != 0 && [searchText length] >= [self noOfLettersInSearch])
    {
        _filteredObjects = [_filteredResults objectForKey:searchText];
        
        if (!_filteredObjects)
        {
            NSPredicate *predicate = [self searchPredicateWithSearchText:searchText scope:scope];

            for (NSString *cachedSearchText in [[_filteredResults allKeys] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"length" ascending:NO]]])
            {
                if ([searchText hasPrefix:cachedSearchText])
                {
                    _filteredObjects = [[_filteredResults objectForKey:cachedSearchText] filteredArrayUsingPredicate:predicate];
                    break;
                }
            }
            
            if (!_filteredObjects)
            {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:mainMOC()];
                fetchRequest.entity = entity;
                
                fetchRequest.predicate = predicate;
                
                NSMutableArray *sortDescriptors = [NSMutableArray new];
                
                for (NSString *key in [self sortKeys])
                {
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
                    [sortDescriptors addObject:sortDescriptor];
                }
                
                if ([sortDescriptors count] > 0)
                    fetchRequest.sortDescriptors = [NSArray arrayWithArray:sortDescriptors];
                
                _filteredObjects = [mainMOC() executeFetchRequest:fetchRequest error:nil];
            }
            
            [_filteredResults setObject:_filteredObjects forKey:searchText];
        }
        
        _noResultsLabel.text = @"No Results";
    }
    else
    {
        _filteredObjects = nil;

        _noResultsLabel.text = [NSString stringWithFormat:@"Enter %d letters or more.", [self noOfLettersInSearch]];
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}


#pragma mark - UISearchDisplayDelegate


- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    _searchVisible = YES;
    
    [self searchTableViewWillShow];
}


- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    _searchVisible = NO;
    
    [self searchTableViewDidHide];
}


- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{

}


- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    _filteredObjects = nil;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (!_noResultsLabel)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.001), dispatch_get_main_queue(), ^(void) {
            for (UIView *v in self.searchDisplayController.searchResultsTableView.subviews)
            {
                if ([v isKindOfClass: [UILabel class]] && [[(UILabel*)v text] isEqualToString:@"No Results"])
                {
                    _noResultsLabel = (UILabel *)v;
                    
                    if ([searchString length] < [self noOfLettersInSearch])
                    {
                        _noResultsLabel.text = [NSString stringWithFormat:@"Enter %d letters or more.", [self noOfLettersInSearch]];
                    }
                    
                    break;
                }
            }
        });
    }
    
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    return YES;
}


#pragma mark - NSFetchedResultsControllerDelegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    _filteredObjects = nil;
    _filteredResults = [NSMutableDictionary new];
    
    [_tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[_tableView cellForRowAtIndexPath:indexPath] forTableView:_tableView atIndexPath:newIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [_tableView deleteRowsAtIndexPaths:[NSArray
                                                arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView insertRowsAtIndexPaths:[NSArray
                                                arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_tableView endUpdates];
}


#pragma mark -


@end