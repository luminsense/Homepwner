//
//  LNGItemCell.h
//  Homepwner
//
//  Created by Lumi on 14-7-29.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LNGItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@property (copy, nonatomic) void (^actionBlock)(void);

@end
