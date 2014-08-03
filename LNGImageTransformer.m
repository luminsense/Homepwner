//
//  LNGImageTransformer.m
//  Homepwner
//
//  Created by Lumi on 14-8-1.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import "LNGImageTransformer.h"
#import <UIKit/UIKit.h>

@implementation LNGImageTransformer

+ (Class)transformedValueClass
{
    return [NSData class];
}

- (id)transformedValue:(id)value
{
    if (!value) {
        return nil;
    }
    
    if ([value isKindOfClass:[NSData class]]) {
        return value;
    }
    
    return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value
{
    return [UIImage imageWithData:value];
}

@end
