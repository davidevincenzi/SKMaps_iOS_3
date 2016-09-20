//
//  SKOneBoxDropdownController.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 17/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxDropdownController.h"
#import "UIColor+SKOneBoxColors.h"
#import "SKOneBoxTableViewCell.h"

#define kAnimateDropDownDuration 0.4
#define kAnimateFadeDuration 0.2

static NSString *const kDropdownControllerCellIdentifier = @"dropdownCell";

@interface SKOneBoxDropdownController ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) UIViewController *parentController;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, strong) SKOneBoxDropdownItem *currentSelectedItem;
@property (nonatomic, assign) NSInteger indexForCurrentSelectedItem;

@end

@implementation SKOneBoxDropdownController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.indexForCurrentSelectedItem = NSNotFound;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.accessibilityIdentifier = @"SKOneBoxDropDownControllerTableView";
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOccured:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.containerView addGestureRecognizer:tapRecognizer];
}

#pragma mark - Properties

- (NSArray *)items {
    return self.dataSource;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        _containerView.backgroundColor = [UIColor hex0000007F];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return _containerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SKOneBoxTableViewCell *cell = nil;
    NSString *cellIdentifier = [SKOneBoxTableViewCell reuseIdentifierForType:SKOneBoxTableViewCellTypeAccessoryLeftImageView];
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[SKOneBoxTableViewCell alloc] initWithType:SKOneBoxTableViewCellTypeAccessoryLeftImageView];
    }
    
    SKOneBoxDropdownItem *currentItem = [self.dataSource objectAtIndex:indexPath.row];
    
    if (currentItem) {
        
        NSInteger count = [self.dataSource count];
        [cell updateSeparatorShowTop:NO showMiddle:(count > 1 && indexPath.row >= 0 && indexPath.row < count-1) showBottom:NO];
        
        UIImage *icon = currentItem.image;
        if (self.currentSelectedItem == currentItem) {
            cell.textColor = [UIColor hex0080FF];
            if (currentItem.activeImage) {
                icon = currentItem.activeImage;
            }
        } else {
            cell.textColor = [UIColor hex3A3A3A];
        }
        
        cell.mainText = [cell attributedMainText:currentItem.title highlightedText:nil];
        cell.leftImage = icon;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SKOneBoxDropdownItem *currentItem = [self.dataSource objectAtIndex:indexPath.row];
    if (currentItem) {
        if (self.singleSelection) {
            [self.dataSource makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
        }

        if (currentItem.selectionBlock) {
            currentItem.selectionBlock(currentItem);
        }
        
        self.currentSelectedItem = currentItem;
        [[self tableView] reloadData];
        
        [self dismiss];
    }
}

#pragma mark - Public methods

- (void)presentInViewController:(UIViewController *)viewController {
    self.parentController = viewController;
    
    self.containerView.frame = ({
        CGRect frame = viewController.view.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        
        frame;
    });
    [self.containerView addSubview:self.tableView];
    
    self.containerView.alpha = 0.0;
    
    [viewController.view addSubview:self.containerView];
    [self presentInViewControllerAnimation];
}

- (void)presentInViewControllerAnimation {
    self.tableView.frame = ({
        CGRect frame = self.parentController.view.frame;
        frame.size = self.tableView.frame.size;
        frame.origin.y = -self.tableView.frame.size.height;
        
        frame;
    });
    
    [UIView animateWithDuration:kAnimateFadeDuration animations:^{
        self.containerView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:kAnimateDropDownDuration animations:^{
        self.tableView.frame = ({
            CGRect frame = self.tableView.frame;
            frame.origin.y += self.tableView.frame.size.height;
            
            frame;
        });
    } completion:^(BOOL finished) {
        self.visible = YES;
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:kAnimateFadeDuration animations:^{
        self.containerView.alpha = 0.0;
    } completion:^(BOOL finished) {

    }];
    [UIView animateWithDuration:kAnimateDropDownDuration animations:^{
        self.tableView.frame = ({
            CGRect frame = self.tableView.frame;
            frame.origin.y = -self.tableView.frame.size.height;
            
            frame;
        });
    } completion:^(BOOL finished) {
        [self.containerView removeFromSuperview];
        self.visible = NO;
    }];
}

- (void)addDropdownItem:(SKOneBoxDropdownItem *)item {
    [self.dataSource addObject:item];

    if (item.isSelected) {
        self.currentSelectedItem = item;
    }
    
    [self.tableView reloadData];
}

- (void)insertDropdownItem:(SKOneBoxDropdownItem *)item atIndex:(NSUInteger)index {
    [self.dataSource insertObject:item atIndex:index];

    if (item.isSelected) {
        self.currentSelectedItem = item;
    }
    
    [self.tableView reloadData];
}

- (void)removeDropdownItem:(SKOneBoxDropdownItem *)item {
    [self.dataSource removeObject:item];
    [self.tableView reloadData];
}

- (void)removeDropdownItemAtIndex:(NSUInteger)index {
    [self.dataSource removeObjectAtIndex:index];
    [self.tableView reloadData];
}

#pragma mark - UITapGestureRecognizer

- (void)tapOccured:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:location];
    
    if (!path) {
        [self dismiss];
    }
}

#pragma mark - Overriden

- (void)setCurrentSelectedItem:(SKOneBoxDropdownItem *)currentSelectedItem {
    _currentSelectedItem = currentSelectedItem;
    self.indexForCurrentSelectedItem = [self.items indexOfObject:currentSelectedItem];
}

@end
