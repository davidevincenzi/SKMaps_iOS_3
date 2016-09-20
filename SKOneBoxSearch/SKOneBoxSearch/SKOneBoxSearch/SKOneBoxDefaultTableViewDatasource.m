//
//  SKOneBoxDefaultTableViewDatasource.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 21/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxDefaultTableViewDatasource.h"
#import "SKOneBoxTableViewCell.h"
#import "SKOneBoxDefaultTableItem.h"
#import "SKOneBoxDefaultSectionItem.h"

@implementation SKOneBoxDefaultTableViewDatasource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SKOneBoxDefaultSectionItem *sectionItem = self.sections[indexPath.section];
    SKOneBoxDefaultTableItem *tableItem = sectionItem.sectionTableItems[indexPath.row];
    
    SKOneBoxTableViewCell *cell = nil;
    NSString *cellIdentifier = nil;
    SKOneBoxTableViewCellType cellType = SKOneBoxTableViewCellTypeAccessoryLeftImageView;
    
    if ([tableItem subTitle]) {
        cellType = SKOneBoxTableViewCellTypeAccessoryLeftImageViewWithSubtitle;
    }
    
    cellIdentifier = [SKOneBoxTableViewCell reuseIdentifierForType:cellType];
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[SKOneBoxTableViewCell alloc] initWithType:cellType];
    }
    
    NSInteger count = [sectionItem.sectionTableItems count];

    //special cases for sections with 1 item.
    //default section case handling
    SKOneBoxDefaultSectionItem *prevSection = nil;
    SKOneBoxDefaultSectionItem *nextSection = nil;
    SKOneBoxDefaultTableItem *nextTableItem = nil;
    
    if (count > indexPath.row + 1) {
        nextTableItem = sectionItem.sectionTableItems[indexPath.row+1];
    }
    if (self.sections.count > indexPath.section+1) {
        nextSection = self.sections[indexPath.section+1];
    }
    if (indexPath.section-1 >= 0) {
        prevSection = self.sections[indexPath.section-1];
    }
    
    //F**K LOGIC
    BOOL showTop = tableItem.showTopSeparator || sectionItem.showHeaderSection || (indexPath.row == 0 && prevSection == nil) || (indexPath.row == 0 && prevSection.showFooterSection);
    BOOL showMiddle = (count > 1 && indexPath.row >= 0 && indexPath.row < count-1 && !nextTableItem.showTopSeparator) || (!nextTableItem.showTopSeparator && !sectionItem.showFooterSection) || !nextSection.showHeaderSection;
    BOOL showBottom = indexPath.row == count-1 && (sectionItem.showFooterSection || nextSection == nil || nextSection.showHeaderSection);
    
    [cell updateSeparatorShowTop:showTop showMiddle:showMiddle showBottom:showBottom];
    
    cell.textColor = tableItem.titleColor;
    cell.textFont = tableItem.titleFont;
    
    cell.mainText = [cell attributedMainText:tableItem.title highlightedText:nil];
    cell.subtitle = [cell attributedSubtitleText:tableItem.subTitle highlightedSubtitleText:nil];
    
    if ([tableItem.rightAccesoryText length]) {
        [cell setAccessoryText:tableItem.rightAccesoryText];
    }
    
    cell.imageView.image = tableItem.image;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SKOneBoxDefaultSectionItem *sectionItem = self.sections[section];
    NSArray *rows = sectionItem.sectionTableItems;
    return rows.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"";
}

@end
