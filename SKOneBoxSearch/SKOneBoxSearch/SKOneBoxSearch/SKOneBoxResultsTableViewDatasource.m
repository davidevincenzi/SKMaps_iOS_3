//
//  SKOneBoxResultsTableViewDatasource.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 22/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxResultsTableViewDatasource.h"
#import "SKOneBoxTableViewCell.h"
#import <SKOSearchLib/SKSearchProviderProtocol.h>
#import <SKOSearchLib/SKOneBoxSearchResult.h>
#import <SKOSearchLib/SKOSearchLibUtils.h>
#import <SKOSearchLib/SKOneBoxSearchResult+TableViewCellHelper.h>
#import "SKOneBoxDebugManager.h"

#define TEST_RELEVANCY 1

@implementation SKOneBoxResultsTableViewDatasource

- (id)init {
    self = [super init];
    if (self) {
        self.shouldShowLoadingCell = YES;
    }
    
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<SKSearchProviderProtocol> searchProvider = self.sections[indexPath.section];
    
    NSArray *results  = [self.dataSource objectForKey:[searchProvider providerID]];
    if (indexPath.row == [results count]) {
        NSString *identifier  = @"loadingCell";
        UITableViewCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!loadingCell) {
            loadingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadingCell"];
        }

        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loadingCell.contentView addSubview:activityIndicatorView];
        activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        activityIndicatorView.center = loadingCell.center;
        activityIndicatorView.tag = 1;
        [activityIndicatorView startAnimating];
        
        loadingCell.tag = 1;
        
        return loadingCell;
    } else {
    
        SKOneBoxSearchResult *searchResult = results[indexPath.row];
        NSString *cellIdentifier = nil;
        
        if (searchProvider.providerResultTableViewCell) {
            UITableViewCell *cell = nil;
            cell = [tableView dequeueReusableCellWithIdentifier:searchProvider.localizedProviderName];
            
            if(!cell){
                cell = searchProvider.providerResultTableViewCell(tableView);
            }
            if (searchProvider.populateResultTableViewCell) {
                searchProvider.populateResultTableViewCell(cell,searchResult);
            }
            
#ifdef TEST_RELEVANCY
            if ([[SKOneBoxDebugManager sharedInstance] testRelevancyEnabled] && ![[SKOneBoxDebugManager sharedInstance] markBadResults]) {
                [self showRelevancy:searchResult cell:cell];
            }
            if ([[SKOneBoxDebugManager sharedInstance] markBadResults]) {
                if ([searchResult expected]) {
                    cell.backgroundColor = [UIColor whiteColor];
                }
                else {
                    cell.backgroundColor = [UIColor redColor];
                }
            }
#endif
            return cell;
        } else {
            //default results cell
            SKOneBoxTableViewCell *cell = nil;
            cellIdentifier = [SKOneBoxTableViewCell reuseIdentifierForType:SKOneBoxTableViewCellTypeAccessoryLeftImageViewWithSubtitle];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if(!cell){
                cell = [[SKOneBoxTableViewCell alloc] initWithType:SKOneBoxTableViewCellTypeAccessoryLeftImageViewWithSubtitle];
            }
            
            cell.mainText = [cell attributedMainText:[searchResult title] highlightedText:self.searchString];
            cell.subtitle = [cell attributedSubtitleText:[searchResult subtitle] highlightedSubtitleText:self.searchString];
            
            //for results it's 
            if (searchResult.additionalInformation[@"categoryIcon"]) {
                cell.leftImage = searchResult.additionalInformation[@"categoryIcon"];
            }
            else if (self.searchResultImage){
                cell.leftImage = self.searchResultImage;
            }
            else if (searchResult.additionalInformation[@"icon"]) {
                cell.leftImage = searchResult.additionalInformation[@"icon"];
            }
            else {
                cell.leftImage = nil;
            }
            
            NSInteger count = [results count];
            [cell updateSeparatorShowTop:NO showMiddle:(count > 1 && indexPath.row >= 0 && indexPath.row < count-1) showBottom:indexPath.row == count-1];
            
#ifdef TEST_RELEVANCY
            if ([[SKOneBoxDebugManager sharedInstance] testRelevancyEnabled] && ![[SKOneBoxDebugManager sharedInstance] markBadResults]) {
                [self showRelevancy:searchResult cell:cell];
            }
            if ([[SKOneBoxDebugManager sharedInstance] markBadResults]) {
                if ([searchResult expected]) {
                    cell.backgroundColor = [UIColor whiteColor];
                }
                else {
                    cell.backgroundColor = [UIColor redColor];
                }
            }
#endif
            
            __weak typeof(cell) wcell = cell;
            
            void (^distanceCalculationBlock)(const double distanceVal) = ^void(const double distanceVal) {
                NSString *formattedDistance = nil;
                if ([self.oneBoxDataSource respondsToSelector:@selector(formatDistance:)]) {
                    formattedDistance = [self.oneBoxDataSource formatDistance:distanceVal];
                }
                
                if (!formattedDistance) {
                    formattedDistance = [NSString stringWithFormat:@"%.0fm",distanceVal];
                }
                
                wcell.accessoryText = formattedDistance;
            };
            
            //calculate air distance
            CLLocationCoordinate2D coordinate = [SKOneBoxSearchPositionerService sharedInstance].currentCoordinate;
            if ((searchResult.coordinate.latitude == 0.0f && searchResult.coordinate.longitude == 0.0f) || (coordinate.latitude == 0.0f && coordinate.longitude == 0.0f)) {
                wcell.accessoryText = nil;
            } else {
                [SKOSearchLibUtils getAsyncAirDistancePointA:searchResult.coordinate pointB:coordinate completionBlock:^(const double result) {
                    distanceCalculationBlock(result);
                }];
            }
            
            return cell;
        }
    }
}

#ifdef TEST_RELEVANCY
-(void)showRelevancy:(SKOneBoxSearchResult*)searchResult cell:(UITableViewCell*)cell {
    switch (searchResult.relevancyType) {
        case SKOneBoxSearchResultLowRelevancy:
        {
            cell.backgroundColor = [UIColor redColor];
        }
            break;
        case SKOneBoxSearchResultMediumRelevancy:
        {
            cell.backgroundColor = [UIColor yellowColor];
        }
            break;
        case SKOneBoxSearchResultHighRelevancy:
        {
            cell.backgroundColor = [UIColor greenColor];
        }
            break;
        default:
            break;
    }
}
#endif

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<SKSearchProviderProtocol> searchProvider = self.sections[section];
    
    NSArray *results = [self.dataSource objectForKey:[searchProvider providerID]];
    if (self.reachedLastPage) {
        return [results count];
    } else {
        if ([results count]) {
            if (self.shouldShowLoadingCell) {
                return [results count] + 1;
            } else {
                return [results count];
            }
        } else {
            return 0;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

@end
