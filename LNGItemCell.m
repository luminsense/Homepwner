//
//  LNGItemCell.m
//  Homepwner
//
//  Created by Lumi on 14-7-29.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import "LNGItemCell.h"

@interface LNGItemCell ()
// @property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation LNGItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)showImage:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock();
    }
}

// DYNAMIC TYPE

- (void)updateInterfaceForDynamicTypeSize
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.nameLabel.font = font;
    self.serialNumberLabel.font = font;
    self.valueLabel.font = font;
    
    // Update image size for dynamic type
    
    static NSDictionary *imageSizeDictionary;
    
    if (!imageSizeDictionary) {
        imageSizeDictionary = @{ UIContentSizeCategoryExtraSmall : @40,
                                 UIContentSizeCategorySmall : @40,
                                 UIContentSizeCategoryMedium : @40,
                                 UIContentSizeCategoryLarge : @40,
                                 UIContentSizeCategoryExtraLarge : @41,
                                 UIContentSizeCategoryExtraExtraLarge : @51,
                                 UIContentSizeCategoryExtraExtraExtraLarge : @56 };
    }
    
    NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    NSNumber *imageSize = imageSizeDictionary[userSize];
    self.imageViewHeightConstraint.constant = imageSize.floatValue;
    // self.imageViewWidthConstraint.constant = imageSize.floatValue;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self updateInterfaceForDynamicTypeSize];
    
    // Responding to user changes of text size
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(updateInterfaceForDynamicTypeSize)
                          name:UIContentSizeCategoryDidChangeNotification
                        object:nil];
    
    // Make the width and height of image the same
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.thumbnailView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.thumbnailView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1
                                                                    constant:0];
    [self.thumbnailView addConstraint:constraint];
}

- (void)dealloc
{
    // Need to remove observer of defaultCenter
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}

@end
