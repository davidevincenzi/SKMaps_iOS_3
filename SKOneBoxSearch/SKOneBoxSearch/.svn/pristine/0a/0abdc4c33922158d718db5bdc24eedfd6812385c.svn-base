//
//  SKOneBoxResultsTableViewDelegate.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxResultsTableViewDelegate.h"
#import "SKOneBoxSearchConstants.h"

@implementation SKOneBoxResultsTableViewDelegate

#pragma mark - Properties

- (void)setSections:(NSArray *)newSections {
    sections = newSections;
}

- (void)startAnimatingSectionViewForProvider:(id<SKSearchProviderProtocol>)provider {
    
}

- (void)stopAnimatingSectionViewForProvider:(id<SKSearchProviderProtocol>)provider {

}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<SKSearchProviderProtocol> selectedSearchProvider = self.sections[indexPath.section];
    if (selectedSearchProvider.providerResultTableViewCell && selectedSearchProvider.customResultsCellHeight != 0.0f) {
        return selectedSearchProvider.customResultsCellHeight;
    }
    else {
        return kRowHeightMultipleLineResult;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<SKSearchProviderProtocol> selectedSearchProvider = self.sections[indexPath.section];
    
    NSArray *searchResultsForProvider = self.dataSource[[selectedSearchProvider providerID]];
    SKOneBoxSearchResult *selectedResult = searchResultsForProvider[indexPath.row];
    
    if ([[SKOneBoxDebugManager sharedInstance] markBadResults]) {
        selectedResult.expected = !selectedResult.expected;
        [selectedResult setExpected:selectedResult.expected];
        [tableView reloadData];
        return;
    }
    
    if (self.selectionBlock) {
        self.selectionBlock(selectedResult, searchResultsForProvider);
    }
}

@end
