//
//  SKOneBoxTableViewDelegate.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 24/03/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxTableViewDelegate.h"
#import "SKOneBoxSectionView.h"
#import "UIColor+SKOneBoxColors.h"
#import "SKOneBoxSearchConstants.h"
#import "SKOneBoxDebugManager.h"

@interface SKOneBoxTableViewDelegate ()

@property (nonatomic, strong) NSMutableDictionary *sectionViews;

@end

@implementation SKOneBoxTableViewDelegate
@dynamic sections;

#pragma mark - Public methods

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.shouldShowSectionHeaders = YES;
        _dataSource = [NSMutableDictionary dictionary];
        _sectionViews = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)setSections:(NSArray *)newSections {
    @synchronized(self) {
        sections = newSections;
        
        for (id<SKSearchProviderProtocol> provider in sections) {
            SKOneBoxSectionView *sectionView = [self sectionViewForProvider:provider];
            
            [self.sectionViews setObject:sectionView forKey:[provider providerID]];
        }
    }
}

-(NSArray*)sections {
    NSArray *ret = nil;
    
    @synchronized(self) {
        ret = sections;
    }
    return ret;
}

- (void)startAnimatingSectionViewForProvider:(id<SKSearchProviderProtocol>)provider {
    SKOneBoxSectionView *sectionView = self.sectionViews[[provider providerID]];
    
    sectionView.loadingLabel.hidden = NO;
    sectionView.loadingView.hidden = NO;
    sectionView.noneToDisplay.hidden = YES;
    [sectionView.loadingView startAnimating];
}

- (void)stopAnimatingSectionViewForProvider:(id<SKSearchProviderProtocol>)provider {
    SKOneBoxSectionView *sectionView = self.sectionViews[[provider providerID]];
    
    sectionView.loadingLabel.hidden = YES;
    sectionView.loadingView.hidden = YES;
    
    [sectionView.loadingView stopAnimating];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<SKSearchProviderProtocol> selectedSearchProvider = self.sections[indexPath.section];
    if (indexPath.row >= selectedSearchProvider.numberOfResultsToShow) {
        return kSeeAllCellHeight;
    }
    else {
        return kRowHeightMultipleLineResult;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id<SKSearchProviderProtocol> selectedSearchProvider = self.sections[indexPath.section];
    
    if (indexPath.row >= selectedSearchProvider.numberOfResultsToShow) {
        if (self.seeAllBlock && selectedSearchProvider) {
            self.seeAllBlock(selectedSearchProvider);
        }
    }
    else {
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
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    id<SKSearchProviderProtocol> provider = self.sections[section];
    NSArray *searchResultsForProvider = self.dataSource[[provider providerID]];
    if (provider.shouldShowSectionHeader && self.shouldShowSectionHeaders ) {
        SKOneBoxSectionView *aview = self.sectionViews[[provider providerID]];
        if (searchResultsForProvider.count) {
            aview.noneToDisplay.hidden = YES;
            aview.alpha = 1.0f;
        } else {
            if (!aview.loadingLabel.hidden) {
                aview.noneToDisplay.hidden = YES;
                aview.alpha = 1.0f;
            } else {
                aview.noneToDisplay.hidden = NO;
                aview.alpha = 0.5f;
            }
        }
        
        aview.separatorView.hidden = [searchResultsForProvider count];
        if ([self.sections count] <= section+1) {
            //last section, no need for separator
            aview.separatorView.hidden = YES;
        }
        
        return aview;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    id<SKSearchProviderProtocol> provider = self.sections[section];
    if (provider.shouldShowSectionHeader && self.shouldShowSectionHeaders) {
        return kSectionHeaderHeight;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == 1) {
        // Loading cell
        UIActivityIndicatorView *activity = (UIActivityIndicatorView*)[[cell contentView] viewWithTag:1];
        [activity startAnimating];
    
        if (self.requestNextPageBlock) {
            id<SKSearchProviderProtocol> provider = self.sections[indexPath.section];
            self.requestNextPageBlock(provider);
        }
        
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.dismissKeyboardBlock) {
        self.dismissKeyboardBlock();
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.didScrollBlock) {
        self.didScrollBlock(scrollView.contentOffset);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.scrollViewDidEndDragging != nil) {
        self.scrollViewDidEndDragging();
    }
}

#pragma mark - Private methods

- (SKOneBoxSectionView *)sectionViewForProvider:(id<SKSearchProviderProtocol>)provider {
    NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
    NSString* libraryBundlePath = [mainBundlePath stringByAppendingPathComponent:@"SKOneBoxSearchBundle.bundle"];
    
    NSBundle *oneBoxBundle = [NSBundle bundleWithPath:libraryBundlePath];
    NSArray *nib = [oneBoxBundle loadNibNamed:@"SKOneBoxSectionView" owner:self options:nil];
    SKOneBoxSectionView *sectionView = nib[0];
    
    [sectionView.loadingView setCircleColor:[UIColor hexB4B4B4]];
    sectionView.loadingLabel.hidden = YES;
    sectionView.loadingView.hidden = YES;
    sectionView.noneToDisplay.hidden = YES;
    
    sectionView.mainLabel.text = provider.localizedProviderName;
    
    return sectionView;
}

@end
