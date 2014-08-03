//
//  LNGItemStore.h
//  Homepwner
//
//  Created by Lumi on 14-7-4.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LNGItem;

@interface LNGItemStore : NSObject

@property (nonatomic, readonly, copy) NSArray *allItems;

// Singleton
+ (instancetype)sharedStore;

- (LNGItem *)createItem;
- (void)removeItem:(LNGItem *)item;
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (BOOL)saveChanges;
- (NSArray *)allAssetTypes;

@end
