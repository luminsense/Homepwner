//
//  LNGImageStore.h
//  Homepwner
//
//  Created by Lumi on 14-7-8.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LNGImageStore : NSObject

+ (instancetype)sharedStore;

- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;
- (void)deleteImageForKey:(NSString *)key;

@end
