//
//  LNGImageViewController.m
//  Homepwner
//
//  Created by Lumi on 14-7-31.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import "LNGImageViewController.h"

@interface LNGImageViewController ()

@end

@implementation LNGImageViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Note:
// 1. Reason for creating a view controller instead of creating imageView directly in LNGItemsViewController: to display in a popover needs a view controller
// 2. Reason for implementing loadView: need to create self.view instead of creating the view from a NIB file.

- (void)loadView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.view = imageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Must cast the view to UIImageView so the compiler knows it is okay to send it setImage;
    UIImageView *imageView = (UIImageView *)self.view;
    imageView.image = self.image;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
