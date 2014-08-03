//
//  LNGItem.m
//  Homepwner
//
//  Created by Lumi on 14-8-1.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import "LNGItem.h"


@implementation LNGItem

@dynamic itemName;
@dynamic serialNumber;
@dynamic valueInDollars;
@dynamic dateCreated;
@dynamic itemKey;
@dynamic thumbnail;
@dynamic orderingValue;
@dynamic assetType;

// When the user creates a new LNGItem instance, it will be added to the database
// When object is addd to the database, this method will be sent
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.dateCreated = [NSDate date];
    
    // Create an NSUUID object and get its string representation
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    self.itemKey = key;
}

- (void)setThumbnailFromImage:(UIImage *)image
{
    CGSize originalImageSize = image.size;
    
    // The rect of the thumbnail
    CGRect newRect = CGRectMake(0, 0, 40, 40);
    
    // Figure out a scaling ratio to make sure we maintain the same aspect ratio
    float ratio = MAX(newRect.size.width / originalImageSize.width, newRect.size.height / originalImageSize.height);
    
    // CREATE a transparent bitmap context with a scaling factor equal to that of the screen
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    // Create a path that is a rounded rect
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    
    // Make all subsequent drawing clip to this rounded rect
    [path addClip];
    
    // Center the image in the thumbnail rect
    CGRect projectRect;
    projectRect.size.width = ratio * originalImageSize.width;
    projectRect.size.height = ratio * originalImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2;
    
    // Draw the image on it
    [image drawInRect:projectRect];
    
    // Get the image from the image context; keep it as our thumbnail
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    self.thumbnail = smallImage;
    
    // CLEANUP image context resources
    UIGraphicsEndImageContext();
}

@end
