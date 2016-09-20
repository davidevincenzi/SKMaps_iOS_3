//
//  SKTNavigationBlockRoadsView.m
//  SDKTools
//

//

#import "SKTNavigationBlockRoadsView.h"
#import "SKTNavigationConstants.h"

#define kFontSize ([UIDevice isiPad] ? 36.0 : 18.0)
#define kCellHeight ([UIDevice isiPad] ? 88.0 : 44.0)

@interface SKTNavigationBlockRoadsView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SKTNavigationBlockRoadsView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self addBackButton];
		[self addTableView];
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

#pragma mark - Overidden

- (void)layoutSubviews {
	[super layoutSubviews];

	_backButton.frameY = self.contentYOffset;
	_tableView.frameY = _backButton.frameMaxY + 12.0;
	_tableView.frameHeight = self.frameHeight - _backButton.frameMaxY - 5.0;
}

- (void)setColorScheme:(NSDictionary *)colorScheme {
    [super setColorScheme:colorScheme];
    
    uint32_t backColor = [self.colorScheme[kSKTGenericBackgroundColorKey] unsignedIntValue];
    uint32_t hiBackColor = [self.colorScheme[kSKTGenericHighlightColorKey] unsignedIntValue];
    uint32_t textColor = [self.colorScheme[kSKTGenericTextColorKey] unsignedIntValue];
    [_backButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:backColor]] forState:UIControlStateNormal];
    [_backButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:hiBackColor alpha:1.0]] forState:UIControlStateHighlighted];
    [_backButton setTitleColor:[UIColor colorWithHex:textColor] forState:UIControlStateNormal];
    
    [_tableView reloadData];
}

#pragma mark - UI creation

- (void)addBackButton {
    _backButton = [UIButton navigationBackButton];
	[_backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_backButton];
}

- (void)addTableView {
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(12.0,
                                                               _backButton.frameMaxY + 12.0,
                                                               self.frameWidth - 24.0,
                                                               self.frameHeight - _backButton.frameMaxY - 5.0)];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.dataSource = self;
	_tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.bounces = NO;
    _tableView.rowHeight = kCellHeight;
	[self addSubview:_tableView];
}

#pragma mark - Public properties

- (void)setDatasource:(NSArray *)datasource {
	_datasource = datasource;
	[_tableView reloadData];
}

#pragma mark - UITableView methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(blockRoadsView:didSelectIndex:)]) {
		[self.delegate blockRoadsView:self didSelectIndex:indexPath.row];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *const cellId = @"SDKTools.BlockRoadsCell";
	UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellId];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
        uint32_t color = [self.colorScheme[kSKTGenericBackgroundColorKey] unsignedIntValue];
        uint32_t highlighColor = [self.colorScheme[kSKTGenericHighlightColorKey] unsignedIntValue];
        UIColor *backgroundColor = [UIColor colorWithHex:color];
        UIColor *hiBackgroundColor = [UIColor colorWithHex:highlighColor alpha:1.0];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.contentView.frameWidth, cell.contentView.frameHeight - 1)];
        background.backgroundColor = backgroundColor;
        background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView insertSubview:background belowSubview:cell.textLabel];

        UIView *selectionBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];
        selectionBackground.backgroundColor = hiBackgroundColor;
        cell.selectedBackgroundView = selectionBackground;
        
        color = [self.colorScheme[kSKTGenericTextColorKey] unsignedIntValue];
        cell.textLabel.textColor = [UIColor colorWithHex:color];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont lightNavigationFontWithSize:kFontSize];
	}

	cell.textLabel.text = _datasource[indexPath.row];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];

	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _datasource.count;
}

#pragma mark - Actions

- (void)backButtonClicked {
	if ([self.delegate respondsToSelector:@selector(blockRoadsViewDidPressBackButton:)]) {
		[self.delegate blockRoadsViewDidPressBackButton:self];
	}
}

@end
