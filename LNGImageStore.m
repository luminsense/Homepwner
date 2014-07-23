//
//  LNGImageStore.m
//  Homepwner
//
//  Created by Lumi on 14-7-8.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import "LNGImageStore.h"

@interface LNGImageStore ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation LNGImageStore

// Ensure singleton
+ (instancetype)sharedStore
{
    static LNGImageStore *sharedStore;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}

- (instancetype)init
{
    [NSException raise:@"Singleton" format:@"Use +[LNGImageStore sharedStore]"];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    [self.dictionary setObject:image forKey:key];
}

- (UIImage *)imageForKey:(NSString *)key
{
    return [self.dictionary objectForKey:key];
}

- (void)deleteImageForKey:(NSString *)key
{
    if (!key) {
        return;
    }
    [self.dictionary removeObjectForKey:key];
}

@end
