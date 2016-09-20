//
//  SKOneBoxLocationView.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKOneBoxLocationView;

@protocol SKOneBoxLocationViewProtocol <NSObject>

-(void)didTapLocationView:(SKOneBoxLocationView*)locationView;
-(void)didTapClearLocation:(SKOneBoxLocationView*)locationView;

@end

@interface SKOneBoxLocationView : UIView

@property (nonatomic, weak) id<SKOneBoxLocationViewProtocol> delegate;
@property (nonatomic, strong) IBOutlet UIImageView *locationImageView;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UIButton *locationButton;
@property (nonatomic, strong) IBOutlet UIView *separatorView;

@end
