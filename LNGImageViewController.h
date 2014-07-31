//
//  LNGImageViewController.h
//  Homepwner
//
//  Created by Lumi on 14-7-31.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LNGImageViewController : UIViewController

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic) CGSize scrollViewFrameSize;

@end
