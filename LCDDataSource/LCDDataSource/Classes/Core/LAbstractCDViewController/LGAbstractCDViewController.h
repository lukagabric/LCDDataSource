//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LAbstractViewController.h"
#import <CoreData/CoreData.h>


@interface LGAbstractCDViewController : LAbstractViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
{
    NSFetchedResultsController *_fetchedResultsController;
    
    __weak UILabel *_noResultsLabel;
    
    __weak IBOutlet UITableView *_tableView;
    
    NSArray *_filteredObjects;    
    NSMutableDictionary *_filteredResults;
    
    BOOL _searchVisible;
}


- (void)cleanup;


@end


#pragma mark - Protected


@interface LGAbstractCDViewController ()


@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;


- (void)displayData;
- (void)searchTableViewWillShow;
- (void)searchTableViewDidHide;
- (void)filterContentForSearchText:(NSString *)searchText scope:(NSInteger)scope;

- (NSString *)entityName;
- (NSArray *)sortDescriptors;
- (NSArray *)sortKeys;
- (NSString *)mainTableSectionNameKeyPath;
- (NSString *)mainTableCache;
- (NSPredicate *)frcPredicate;
- (NSPredicate *)searchPredicateWithSearchText:(NSString *)searchText scope:(NSInteger)scope;
- (NSUInteger)noOfLettersInSearch;
- (NSUInteger)fetchBatchSize;
- (BOOL)showIndexes;
- (void)configureCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;


@end