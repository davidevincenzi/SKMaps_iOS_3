//
//  SKOneBoxSectionView.h
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 25/03/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKLoadingIndicator.h"

@interface SKOneBoxSectionView : UIView

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet SKLoadingIndicator *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *noneToDisplay;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end
