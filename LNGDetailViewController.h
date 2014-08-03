//
//  LNGDetailViewController.h
//  Homepwner
//
//  Created by Lumi on 14-7-6.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNGItem;

@interface LNGDetailViewController : UIViewController <UIViewControllerRestoration>

@property (nonatomic, strong) LNGItem *item;
@property (nonatomic, copy) void (^dismissBlock)(void);

- (instancetype)initForNewItem:(BOOL)isNew;

@end
