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

@interface LNGItemsViewController () <UIPopoverControllerDelegate>
@property (strong, nonatomic) UIPopoverController *imagePopover;
@end

@implementation LNGItemsViewController

// INIT METHODS

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.navigationItem.title = @"Homepwner";
        
        // Create a bar button item
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        self.navigationItem.rightBarButtonItem = bbi;
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }
    return self;
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
    
    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"LNGItemCell" bundle:nil];
    
    // Register this NIB
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LNGItemCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

// TABLE VIEW DATA SOURCE AND DELEGATE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[LNGItemStore sharedStore] allItems] count];
}

// There will be a problem if this method is not implemented
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
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
    cell.valueLabel.text = [NSString stringWithFormat:@"$%d", item.valueInDollars];
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
            CGSize contentSize = CGSizeMake(600, 600);
            ivc.scrollViewFrameSize = contentSize;
            self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
            self.imagePopover.delegate = self;
            self.imagePopover.popoverContentSize = contentSize;
            [self.imagePopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    };
    
    return cell;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePopover = nil;
}

// NAVIGATION

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LNGDetailViewController *detailViewController = [[LNGDetailViewController alloc] initForNewItem:NO];
    
    NSArray *items = [[LNGItemStore sharedStore] allItems];
    LNGItem *selectedItem = items[indexPath.row];
    detailViewController.item = selectedItem;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

// TABLE VIEW EDITING

- (IBAction)addNewItem:(id)sender
{
    if (!self.editing) {
        LNGItem *newItem = [[LNGItemStore sharedStore] createItem];
        
        /*
        //NSInteger lastRow = [[[LNGItemStore sharedStore] allItems] indexOfObject:newItem];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        // Insert this new row into the table
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
         */
        
        LNGDetailViewController *detailViewController = [[LNGDetailViewController alloc] initForNewItem:YES];
        detailViewController.item = newItem;
        detailViewController.dismissBlock = ^{
            [self.tableView reloadData];
        };
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;        
        navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:navController animated:YES completion:NULL];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[LNGItemStore sharedStore] removeItemAtIndex:indexPath.row];
        // Also remove the row
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[LNGItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

@end
