//
//  FMRecentsTableViewCell.h
//  ForeverMapNGX
//
//  Created by Mihai Babici on 2/7/13.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKOneBoxRecentsTableViewCell : UITableViewCell <UITextFieldDelegate> {
    UITextField     *_mainTextField;
}

@property (nonatomic, readonly) UIImageView     *mainImageView;
@property (nonatomic, readonly) UILabel         *mainLabel;
@property (nonatomic, readonly) UILabel         *detailsLabel; // Set text to nil, empty or whitespace to not display this info
@property (nonatomic, readonly) UILabel         *infoLabel; // Set text to nil, empty or whitespace to not display this info
@property (nonatomic, readonly) UILabel         *secondInfoLabel; // Set text to nil, empty or whitespace to not display this info
@property (nonatomic, readonly) UIImageView     *accessoryImageView; // Set only the image for this custom accessory view
@property (nonatomic, readwrite) UIView         *separatorView;
@property (nonatomic, readwrite) UIView         *verticalSeparatorView;
@property (nonatomic, readwrite) UIImageView    *navigateImageView;
@property (nonatomic, copy)   void (^didTapAccessoryRegion)(void);
@property (nonatomic, copy)   void (^didTapMainImageView)(void);

@property (nonatomic, strong) UILabel           *dateAutomationDebug;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)editMainLabelWithStartBlock:(void (^)(void))startBlock completionBlock:(void (^)(NSString *newName))completionBlock;
- (void)cellTextFieldResignFirstResponder;

@end
