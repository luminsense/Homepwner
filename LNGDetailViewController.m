//
//  LNGDetailViewController.m
//  Homepwner
//
//  Created by Lumi on 14-7-6.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import "LNGDetailViewController.h"
#import "LNGItem.h"
#import "LNGImageStore.h"
#import "LNGCameraOverlayView.h"

@interface LNGDetailViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@end

@implementation LNGDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    // set the vertical priorities to be less than those of the other subviews
    [self.imageView setContentHuggingPriority:200 forAxis:UILayoutConstraintAxisVertical];
    [self.imageView setContentCompressionResistancePriority:700 forAxis:UILayoutConstraintAxisVertical];
    
    NSDictionary *nameMap = @{@"imageView" : self.imageView,
                              @"valueField" : self.valueField,
                              @"toolBar" : self.toolBar};
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:nameMap];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[valueField]-[imageView]-[toolBar]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:nameMap];
    [self.view addConstraints:horizontalConstraints];
    [self.view addConstraints:verticalConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    LNGItem *item = self.item;
    
    self.nameField.text = item.itemName;
    self.serialNumberField.text = item.serialNumber;
    self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    self.dateLabel.text = [dateFormatter stringFromDate:item.dateCreated];
    
    // Grab the image for the item
    NSString *itemKey = self.item.itemKey;
    UIImage *imageToDisplay = [[LNGImageStore sharedStore] imageForKey:itemKey];
    self.imageView.image = imageToDisplay;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Clear first responder
    [self.view endEditing:YES];
    
    // Save changed to item
    LNGItem *item = self.item;
    item.itemName = self.nameField.text;
    item.serialNumber = self.serialNumberField.text;
    item.valueInDollars = [self.valueField.text intValue];
}

- (void)setItem:(LNGItem *)item
{
    _item = item;
    self.navigationItem.title = _item.itemName;
}

- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // [textField endEditing:YES];
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)takePicture:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Check if the device has a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        CGRect cameraOverlayFrame = CGRectMake(270, 300, 100, 100);
        LNGCameraOverlayView *cameraOverlayView = [[LNGCameraOverlayView alloc] initWithFrame:cameraOverlayFrame];
        imagePicker.cameraOverlayView = cameraOverlayView;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    // Set delegate
    imagePicker.delegate = self;
    
    // Present modal view
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (IBAction)deletePicture:(id)sender {
    self.imageView.image = nil;
    [[LNGImageStore sharedStore] deleteImageForKey:self.item.itemKey];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    // Store the image in the LNGImageStore for this key
    [[LNGImageStore sharedStore] setImage:image forKey:self.item.itemKey];
    
    self.imageView.image = image;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
