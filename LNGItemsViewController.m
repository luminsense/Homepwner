//
//  LNGItemsViewController.m
//  Homepwner
//
//  Created by Lumi on 14-7-4.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import "LNGItemsViewController.h"
#import "LNGDetailViewController.h"
#import "LNGItem.h"
#import "LNGItemStore.h"
#import "LNGItemCell.h"
#import "LNGImageStore.h"
#import "LNGImageViewController.h"

@interface LNGItemsViewController () <UIPopoverControllerDelegate, UIDataSourceModelAssociation>
@property (strong, nonatomic) UIPopoverController *imagePopover;
@end

@implementation LNGItemsViewController

#pragma mark - View Controller Life Cycle

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Homepwner", @"Name of the application");
        
        // Set restoration identifier and restoration class
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        // Create a bar button item
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        self.navigationItem.rightBarButtonItem = bbi;
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        
        // Responding to user changes of text size
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self
                          selector:@selector(updateTableViewForDynamicTypesize)
                              name:UIContentSizeCategoryDidChangeNotification
                            object:nil];
        
        // Responding to locale change
        [defaultCenter addObserver:self
                          selector:@selector(localeChanged:)
                              name:NSCurrentLocaleDidChangeNotification
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

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register a class with identifier for table view
    // [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    // Load the NIB file for table view cell
    UINib *nib = [UINib nibWithNibName:@"LNGItemCell" bundle:nil];
    
    // Register this NIB
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LNGItemCell"];
    
    self.tableView.restorationIdentifier = @"LNGItemsViewControllerTableView";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // update for dynamic type
    [self updateTableViewForDynamicTypesize];
}

#pragma mark - Table View Data Source and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[LNGItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create an instance of UITableViewCell, with default appearance
    LNGItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LNGItemCell" forIndexPath:indexPath];
    NSArray *items = [[LNGItemStore sharedStore] allItems]; // copy
    LNGItem *item = items[indexPath.row];
    
    // Configure the cell with LNGItem
    cell.nameLabel.text = item.itemName;
    cell.serialNumberLabel.text = item.serialNumber;
    // Create a number formatter for currency
    static NSNumberFormatter *currencyFormatter = nil;
    if (currencyFormatter == nil) {
        currencyFormatter = [[NSNumberFormatter alloc] init];
        currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    }
    cell.valueLabel.text = [currencyFormatter stringFromNumber:@(item.valueInDollars)];
    cell.valueLabel.textColor = item.valueInDollars > 50.0 ? [UIColor greenColor] : [UIColor blackColor];
    cell.thumbnailView.image = item.thumbnail;
    
    // Configure actionBlock for the viewing big image feature
    __weak LNGItemCell *weakCell = cell;
    cell.actionBlock = ^{
        NSLog(@"Going to show image for %@", item);
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            NSString *itemKey = item.itemKey;
            
            LNGItemCell *strongCell = weakCell;
            
            // If there is no image, don't need to display anything
            UIImage *image = [[LNGImageStore sharedStore] imageForKey:itemKey];
            if (!image) {
                return;
            }
            
            // Make a rect for the frame of the thumbnail relative to our table view
            CGRect rect = [self.view convertRect:strongCell.thumbnailView.bounds fromView:strongCell.thumbnailView];
            
            // Create a new LNGImageViewController and set its image
            LNGImageViewController *ivc = [[LNGImageViewController alloc] init];
            ivc.image = image;
            
            // Present a 600x600 popover from the rect
            self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
            self.imagePopover.delegate = self;
            self.imagePopover.popoverContentSize = CGSizeMake(600, 600);
            [self.imagePopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            NSLog(@"Size: %f, %f", self.imagePopover.popoverContentSize.width, self.imagePopover.popoverContentSize.height);
        }
    };
    
    return cell;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePopover = nil;
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LNGDetailViewController *detailViewController = [[LNGDetailViewController alloc] initForNewItem:NO];
    
    NSArray *items = [[LNGItemStore sharedStore] allItems];
    LNGItem *selectedItem = items[indexPath.row];
    detailViewController.item = selectedItem;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Table View Editing

- (IBAction)addNewItem:(id)sender
{
    if (!self.editing) {
        LNGItem *newItem = [[LNGItemStore sharedStore] createItem];
        
        // The init method is key
        LNGDetailViewController *detailViewController = [[LNGDetailViewController alloc] initForNewItem:YES];
        detailViewController.item = newItem;
        detailViewController.dismissBlock = ^{
            [self.tableView reloadData];
        };
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        
        navController.restorationIdentifier = NSStringFromClass([navController class]);
        
        navController.modalPresentationStyle = UIModalPresentationFormSheet;        
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:navController animated:YES completion:NULL];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LNGItem *item = [[[LNGItemStore sharedStore] allItems] objectAtIndex:indexPath.row];
        [[LNGItemStore sharedStore] removeItem:item];
        // Also remove the row
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[LNGItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

#pragma mark - Notification Center

- (void)updateTableViewForDynamicTypesize
{
    static NSDictionary *cellHeightDictionary;
    
    if (!cellHeightDictionary) {
        cellHeightDictionary = @{ UIContentSizeCategoryExtraSmall : @44,
                                  UIContentSizeCategorySmall : @44,
                                  UIContentSizeCategoryMedium : @44,
                                  UIContentSizeCategoryLarge : @44,
                                  UIContentSizeCategoryExtraLarge : @50,
                                  UIContentSizeCategoryExtraExtraLarge : @55,
                                  UIContentSizeCategoryExtraExtraExtraLarge : @60 };
    }
    
    NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    
    NSNumber *cellHeight = cellHeightDictionary[userSize];
    [self.tableView setRowHeight:cellHeight.floatValue];
    [self.tableView reloadData];
}

- (void)localeChanged:(NSNotification *)note
{
    [self.tableView reloadData];
}

#pragma mark - State Restoration

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return [[self alloc] init];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeBool:self.isEditing forKey:@"TableViewIsEditing"];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.editing = [coder decodeBoolForKey:@"TableViewIsEditing"];
    [super decodeRestorableStateWithCoder:coder];
}

- (NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view
{
    NSString *identifier = nil;
    if (idx && view) {
        // Return an identifier of the given NSIndexPath, in case next time the data source changes
        LNGItem *item = [[LNGItemStore sharedStore] allItems][idx.row];
        identifier = item.itemKey;
    }
    return identifier;
}

- (NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
    NSIndexPath *indexPath = nil;
    
    if (identifier && view) {
        NSArray *items = [[LNGItemStore sharedStore] allItems];
        for (LNGItem *item in items) {
            if ([identifier isEqualToString:item.itemKey]) {
                int row = [items indexOfObjectIdenticalTo:item];
                indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            }
        }
    }
    
    return indexPath;
}

@end
