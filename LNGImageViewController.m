//
//  LNGImageViewController.m
//  Homepwner
//
//  Created by Lumi on 14-7-31.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import "LNGImageViewController.h"

@interface LNGImageViewController () <UIScrollViewDelegate>

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
// 1. Reason for creating a view controller instead of creating imageView directly in LNGItemsViewController: need to display in a popover
// 2. Reason for implementing loadView: need to create self.view instead of creating the view from a NIB file.

- (void)loadView
{
    CGRect frame = CGRectMake(0, 0, self.scrollViewFrameSize.width, self.scrollViewFrameSize.height);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView.delegate = self;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.minimumZoomScale = 0.1;
    
    self.imageView = [[UIImageView alloc] init];
    [self.scrollView addSubview:self.imageView];
    self.view = self.scrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // To-do: fix that issue
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Must cast the view to UIImageView so the compiler knows it is okay to send it setImage;
    // UIImageView *imageView = (UIImageView *)self.view.subviews[1];\\
    
    self.imageView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    
    self.scrollView.contentSize = self.imageView.bounds.size;

    self.imageView.image = self.image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    float centerPointX = self.scrollView.bounds.size.width > self.imageView.bounds.size.width ? self.scrollView.bounds.size.width / 2 : self.imageView.bounds.size.width / 2 ;
    float centerPointY = self.scrollView.bounds.size.height > self.imageView.bounds.size.height ? self.scrollView.bounds.size.height / 2 : self.imageView.bounds.size.height / 2 ;
    self.imageView.center = CGPointMake(centerPointX, centerPointY);
    
    float offsetX = self.scrollView.bounds.size.width > self.imageView.bounds.size.width ? 0 : (self.imageView.bounds.size.width - self.scrollView.bounds.size.width) / 2;
    float offsetY = self.scrollView.bounds.size.height > self.imageView.bounds.size.height ? 0 : (self.imageView.bounds.size.height - self.scrollView.bounds.size.height) / 2;
    [self.scrollView setContentOffset:CGPointMake(offsetX, offsetY) animated:NO];
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
