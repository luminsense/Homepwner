//
//  LNGItemStore.m
//  Homepwner
//
//  Created by Lumi on 14-7-4.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import "LNGItemStore.h"
#import "LNGImageStore.h"
#import "LNGItem.h"

@interface LNGItemStore()
@property (nonatomic) NSMutableArray *privateItems;
@end

@implementation LNGItemStore

+ (instancetype)sharedStore
{
    static LNGItemStore *sharedStore;
    
    // Make thread safe
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });

    return sharedStore;
}

// [[LNGItemStore alloc] init] will create an error
- (instancetype)init
{
    [NSException raise:@"Singleton" format:@"Use + [LNGItemStore sharedStore"];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        // _privateItems = [[NSMutableArray alloc] init];
        
        NSString *path = [self itemArchivePath];
        _privateItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!_privateItems) {
            _privateItems = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (NSArray *)allItems
{
    return [self.privateItems copy];
}

- (LNGItem *)createItem
{
    LNGItem *item = [[LNGItem alloc] init];
    [self.privateItems insertObject:item atIndex:0];
    return item;
}

- (void)removeItem:(LNGItem *)item
{
    NSString *key = item.itemKey;
    
    // Delete the corresponding image with the key
    [[LNGImageStore sharedStore] deleteImageForKey:key];
    
    [self.privateItems removeObjectIdenticalTo:item];
}

- (void)removeItemAtIndex:(NSUInteger)index
{
    [self.privateItems removeObjectAtIndex:index];
}

- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }
    LNGItem *item = self.privateItems[fromIndex];
    [self.privateItems removeObjectAtIndex:fromIndex];
    [self.privateItems insertObject:item atIndex:toIndex];
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"]; // this is the file name
}

- (BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.privateItems toFile:path];
}

@end
