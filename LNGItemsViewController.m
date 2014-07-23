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

@interface LNGItemsViewController ()

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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create an instance of UITableViewCell, with default appearance
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    NSArray *items = [[LNGItemStore sharedStore] allItems]; // copy
    LNGItem *item = items[indexPath.row];
    cell.textLabel.text = [item description];
    return cell;
}

// NAVIGATION

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LNGDetailViewController *detailViewController = [[LNGDetailViewController alloc] init];
    
    NSArray *items = [[LNGItemStore sharedStore] allItems];
    LNGItem *selectedItem = items[indexPath.row];
    detailViewController.item = selectedItem;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

// TABLE VIEW EDITING

- (IBAction)addNewItem:(id)sender
{
    if (!self.editing) {
        [[LNGItemStore sharedStore] createItem];
        
        //NSInteger lastRow = [[[LNGItemStore sharedStore] allItems] indexOfObject:newItem];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        // Insert this new row into the table
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
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
