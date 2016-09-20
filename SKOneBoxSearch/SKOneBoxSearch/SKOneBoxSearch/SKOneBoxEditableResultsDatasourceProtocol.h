//
//  SKOneBoxEditableDatasource.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKOneBoxEditableResultsViewController.h"
#import <SKOSearchLib/SKOneBoxSearchResult.h>

@class SKOneBoxEditableResultsViewController;

@protocol SKOneBoxEditableResultsDatasourceProtocol <NSObject, UITableViewDataSource>

@property (nonatomic, strong, readwrite) UITableView                        *tableView;
@property (nonatomic, strong, readonly)  NSArray                            *sortingComparators;

@property (nonatomic, strong, readonly)  NSArray                            *datasource;
@property (nonatomic, strong, readonly)  NSArray                            *cachedDatasource;
@property (nonatomic, strong, readwrite) NSMutableArray                     *selectedDatasource;

@property (nonatomic, strong, readonly)  NSArray                            *sectionTimeTitles;
@property (nonatomic, strong, readwrite) SKOneBoxSearchComparator           *currentComparator;
@property (nonatomic, strong, readwrite) NSString                           *searchPlaceholder;
@property (nonatomic, strong, readwrite) NSString                           *title;

@property (nonatomic, copy) void                        (^didSelectRowWithDatasourceItem)(id);
@property (nonatomic, copy) void                        (^didSelectAddNewElement)(id);
@property (nonatomic, copy) void                        (^didSelectAccessoryRegionOfPOI)(id);

@property (nonatomic, weak) SKOneBoxEditableResultsViewController           *editableViewController;

- (void)reloadData;
- (void)sortWithComparator:(id)comparator;
- (void)filterSearch:(NSString *)filterText;

//Edit Mode
- (void)didToggleSelectAllItems;
- (void)didSelectDatasourceItem:(id)datasourceItem;
- (void)didTapDeleteButton;
- (void)shouldDisplayInEditMode:(BOOL)value;

@optional
- (void)addSearchResult:(SKOneBoxSearchResult*)searchResult;

@end
