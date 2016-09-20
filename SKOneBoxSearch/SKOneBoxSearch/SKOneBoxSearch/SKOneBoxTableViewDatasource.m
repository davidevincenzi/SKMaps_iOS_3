//
//  SKOneBoxTableViewDatasource.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 24/03/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxTableViewDatasource.h"
#import "SKOneBoxTableViewCell.h"
#import <SKOSearchLib/SKSearchProviderProtocol.h>
#import <SKOSearchLib/SKOneBoxSearchResult.h>
#import <SKOSearchLib/SKOSearchLibUtils.h>
#import "UIColor+SKOneBoxColors.h"
#import <SKOSearchLib/SKOneBoxSearchResult+TableViewCellHelper.h>
#import "SKOneBoxSearchPositionerService.h"
#import "SKOneBoxDebugManager.h"

#define TEST_RELEVANCY 1

@interface SKOneBoxTableViewDatasource ()

@end

@implementation SKOneBoxTableViewDatasource

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _sections = [NSArray array];
        _dataSource = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - Private

-(NSString*)placeStringFromResult:(SKOneBoxSearchResult*)searchResult {
    NSString *place = searchResult.locality;
    if (!place) {
        place = searchResult.subLocality;
    }
    if (!place && [[searchResult additionalInformation] valueForKey:@"onelineAddress"]) {
        NSArray *componentsOneline = [[[searchResult additionalInformation] valueForKey:@"onelineAddress"] componentsSeparatedByString:@","];
        if ([componentsOneline count]) {
            place = componentsOneline[0];
        }
    }
    return place;
}

#pragma mark - UITableViewDatasource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<SKSearchProviderProtocol> searchProvider = self.sections[indexPath.section];
    if (indexPath.row >= searchProvider.numberOfResultsToShow) {
        NSString *cellIdentifier = [SKOneBoxTableViewCell reuseIdentifierForType:SKOneBoxTableViewCellTypeNoAccessory];
        SKOneBoxTableViewCell *seeAllCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!seeAllCell) {
            seeAllCell = [[SKOneBoxTableViewCell alloc] initWithType:SKOneBoxTableViewCellTypeNoAccessory];
        }
        
        seeAllCell.textFont = [UIFont fontWithName:@"Avenir-Roman" size:13];
        seeAllCell.textColor = [UIColor hex0080FF];
        seeAllCell.mainText = [seeAllCell attributedMainText:[NSString stringWithFormat:SKOneBoxLocalizedString(@"see_all_COUNT_PROVIDER_results", nil), searchProvider.localizedProviderName] highlightedText:nil];
        
        seeAllCell.tag = 2;
        
        [seeAllCell updateSeparatorShowTop:YES showMiddle:NO showBottom:NO];
        
        return seeAllCell;
    }
    else {
        SKOneBoxTableViewCell *cell = nil;
        NSString *cellIdentifier = [SKOneBoxTableViewCell reuseIdentifierForType:SKOneBoxTableViewCellTypeAccessoryLeftImageViewWithSubtitle];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(!cell){
            cell = [[SKOneBoxTableViewCell alloc] initWithType:SKOneBoxTableViewCellTypeAccessoryLeftImageViewWithSubtitle];
        }
        
        SKOneBoxSearchResult *searchResult = self.dataSource[[searchProvider providerID]][indexPath.row];
        
        NSAttributedString *title = nil;
        NSAttributedString *subtitle = nil;
        
        if ([[searchResult additionalInformation] valueForKey:@"locationSuggestion"]) {
            //location suggestion
            NSString *place = [self placeStringFromResult:searchResult];
            title = [cell attributedMainText:[NSString stringWithFormat:SKOneBoxLocalizedString(@"search_SMTH_in_LOCATION_question_key", nil), place] highlightedText:place];
            subtitle = [cell attributedSubtitleText:[NSString stringWithFormat:@"%f %f",searchResult.coordinate.latitude,searchResult.coordinate.longitude] highlightedSubtitleText:nil];
            cell.accessoryText = nil;
        }
        else {
            title = [cell attributedMainText:[searchResult title] highlightedText:self.searchString];
            subtitle = [cell attributedSubtitleText:[searchResult subtitle] highlightedSubtitleText:self.searchString];
            
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
                
                //this color should be a property of the provider
                wcell.textColor = [UIColor hex3A3A3A];
            };
            
            //calculate air distance
            CLLocationCoordinate2D coordinate = [SKOneBoxSearchPositionerService sharedInstance].currentCoordinate;
            if ((searchResult.coordinate.latitude == 0.0f && searchResult.coordinate.longitude == 0.0f) || (coordinate.latitude == 0.0f && coordinate.longitude == 0.0f)) {
                wcell.accessoryText = nil;
            }
            else {
                [SKOSearchLibUtils getAsyncAirDistancePointA:searchResult.coordinate pointB:coordinate completionBlock:^(const double result) {
                    distanceCalculationBlock(result);
                }];
            }
        }
        
        cell.mainText = title;
        cell.subtitle = subtitle;
        
        if (searchResult.additionalInformation[@"icon"]) {
            cell.leftImage = searchResult.additionalInformation[@"icon"];
        }
        else {
            cell.leftImage = searchProvider.providerIcon;
        }
        
#ifdef TEST_RELEVANCY
        if ([[SKOneBoxDebugManager sharedInstance] testRelevancyEnabled] && ![[SKOneBoxDebugManager sharedInstance] markBadResults]) {
            [self showRelevancy:searchResult cell:cell];
        }
        else {
            [self showTopResult:searchResult cell:cell];
            if ([[SKOneBoxDebugManager sharedInstance] markBadResults]) {
                if ([searchResult expected]) {
                    cell.backgroundColor = [UIColor whiteColor];
                }
                else {
                    cell.backgroundColor = [UIColor redColor];
                }
            }
        }
#else
        [self showTopResult:searchResult cell:cell];
#endif
        
        NSInteger count = MIN([[self.dataSource objectForKey:[searchProvider providerID]] count], searchProvider.numberOfResultsToShow);
        [cell updateSeparatorShowTop:NO showMiddle:(count > 1 && indexPath.row >= 0 && indexPath.row < count-1) showBottom:NO];
        
        return cell;
    }
}

-(void)showTopResult:(SKOneBoxSearchResult*)searchResult cell:(UITableViewCell*)cell {
    if ([searchResult topResult]) {
        cell.backgroundColor = [UIColor hexF2F9FF];
    }
    else {
        cell.backgroundColor = [UIColor whiteColor];
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
    
    return MIN([[self.dataSource objectForKey:[searchProvider providerID]] count], searchProvider.numberOfResultsToShow+1);
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

@end
