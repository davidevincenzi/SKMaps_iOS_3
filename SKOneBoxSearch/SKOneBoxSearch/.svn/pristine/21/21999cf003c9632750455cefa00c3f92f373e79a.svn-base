//
//  SKOneBoxDefaultTableViewDelegate.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 21/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxDefaultTableViewDelegate.h"
#import "SKOneBoxDefaultTableItem.h"
#import "SKOneBoxDefaultSectionItem.h"
#import "UIColor+SKOneBoxColors.h"

@implementation SKOneBoxDefaultTableViewDelegate

#pragma mark - Properties

- (void)setSections:(NSArray *)newSections {
    sections = newSections;
}

- (void)startAnimatingSectionViewForProvider:(id<SKSearchProviderProtocol>)provider {
}

- (void)stopAnimatingSectionViewForProvider:(id<SKSearchProviderProtocol>)provider {
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    SKOneBoxDefaultSectionItem *sectionItem = self.sections[section];
    return sectionItem.headerSectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SKOneBoxDefaultSectionItem *sectionItem = self.sections[indexPath.section];
    SKOneBoxDefaultTableItem *selectedItem = sectionItem.sectionTableItems[indexPath.row];
    return selectedItem.itemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SKOneBoxDefaultSectionItem *sectionItem = self.sections[indexPath.section];
    SKOneBoxDefaultTableItem *selectedResult = sectionItem.sectionTableItems[indexPath.row];
    if (selectedResult.selectionBlock) {
        selectedResult.selectionBlock();
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SKOneBoxDefaultSectionItem *sectionItem = self.sections[section];
    if (sectionItem.showHeaderSection) {
        UIView *sectionView = [UIView new];
        sectionView.backgroundColor = [UIColor hexF3F3F3];
        return sectionView;
    }
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    SKOneBoxDefaultSectionItem *sectionItem = self.sections[section];
    if (sectionItem.showFooterSection) {
        UIView *sectionView = [UIView new];
        sectionView.backgroundColor = [UIColor hexF3F3F3];
        return sectionView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    SKOneBoxDefaultSectionItem *sectionItem = self.sections[section];
    if (sectionItem.showFooterSection) {
        return sectionItem.footerSectionHeight;
    }
    return 0;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
