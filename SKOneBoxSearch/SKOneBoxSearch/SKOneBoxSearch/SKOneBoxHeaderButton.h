//
//  SKOneBoxHeaderButton.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKOneBoxHeaderButton : UIButton

@property (nonatomic, strong, readonly) void (^selectionBlock)();
@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UIImageView *iconView;

@property (nonatomic, strong, readonly) UIImage *inactiveStateImage;
@property (nonatomic, strong, readonly) UIImage *activeStateImage;
@property (nonatomic, strong, readonly) UIImage *selectedStateImage;

- (id)initWithTitle:(NSString*)title activeImage:(UIImage*)activeImage selectedImage:(UIImage*)selectedImage inactiveImage:(UIImage*)inactiveImage andSelectionBlock:(void (^)(void))selectionBlock;

@end
