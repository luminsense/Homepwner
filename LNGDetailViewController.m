//
//  LNGDetailViewController.m
//  Homepwner
//
//  Created by Lumi on 14-7-6.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import "LNGDetailViewController.h"
#import "LNGItem.h"
#import "LNGItemStore.h"
#import "LNGImageStore.h"
#import "LNGCameraOverlayView.h"

@interface LNGDetailViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
@property (strong, nonatomic) UIPopoverController *imagePickerPopover;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end

@implementation LNGDetailViewController

- (instancetype)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        if (isNew) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = doneItem;
            
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
        
        // Responding to user changes of text size
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self
                          selector:@selector(updateFonts)
                              name:UIContentSizeCategoryDidChangeNotification
                            object:nil];
    }
    return self;
}

- (void)dealloc
{
    // Need to remove observer of defaultCenter
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [NSException raise:@"Wrong initializer" format:@"User initForNewItem"];
    return nil;
}

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
    
    // prepare for orientation
    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareViewsForOrientation:io];
    
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
    
    // Using dynamic type
    [self updateFonts];
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

// FORM EDITING

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

// TAKING PICTURE

- (IBAction)takePicture:(id)sender
{
    // Avoid crash when calling another popover controller
    if ([self.imagePickerPopover isPopoverVisible]) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        return;
    }
    
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
    
    // [self presentViewController:imagePicker animated:YES completion:NULL];
    
    // Place image picker on the screen (check for iPad device before presenting popover controller)
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        self.imagePickerPopover.delegate = self;
        [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}

- (IBAction)deletePicture:(id)sender {
    self.imageView.image = nil;
    [[LNGImageStore sharedStore] deleteImageForKey:self.item.itemKey];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    // Create a thunmnail
    [self.item setThumbnailFromImage:image];
    
    // Store the image in the LNGImageStore for this key
    [[LNGImageStore sharedStore] setImage:image forKey:self.item.itemKey];
    
    self.imageView.image = image;
    
    // Dismiss the popover controller if have
    if (self.imagePickerPopover) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

// ROTATION HANDLING

- (void)prepareViewsForOrientation:(UIInterfaceOrientation)orientation
{
    // is it an iPad? No preparation necessary
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return;
    }
    
    // is it landscape?
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.imageView.hidden = YES;
        self.cameraButton.enabled = NO;
    } else {
        self.imageView.hidden = NO;
        self.cameraButton.enabled = YES;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self prepareViewsForOrientation:toInterfaceOrientation];
}

// POPOVER CONTROLLER

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePickerPopover = nil;
}

// MODAL VIEW BUTTONS

- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void)cancel:(id)sender
{
    [[LNGItemStore sharedStore] removeItem:self.item];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

// DYNAMIC TYPE

- (void)updateFonts
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.nameLabel.font = font;
    self.serialNumberLabel.font = font;
    self.valueLabel.font = font;
    self.dateLabel.font = font;
    
    self.nameField.font = font;
    self.serialNumberField.font = font;
    self.valueField.font = font;
}


@end
