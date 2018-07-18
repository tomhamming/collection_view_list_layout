//
//  ListCollectionViewCell.m
//  CollectionListLayoutTesting
//
//  Created by Hamming, Tom on 7/18/18.
//  Copyright © 2018 Olive Tree Bible Software. All rights reserved.
//

#import "ListCollectionViewCell.h"

@interface ListCollectionViewCell ()
@property (readwrite) UILabel *label;
@end

@implementation ListCollectionViewCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.label = [[UILabel alloc]init];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.label];
        [self.label.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:15].active = YES;
        [self.label.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:15].active = YES;
        [self.label.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:-15].active = YES;
        [self.label.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-15].active = YES;
        self.label.numberOfLines = 0;
        self.label.font = [UIFont systemFontOfSize:17];
        self.label.textColor = [UIColor blackColor];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = self.contentView.backgroundColor;
        self.contentView.layer.borderWidth = 1;
        self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    return self;
}

-(UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    UICollectionViewLayoutAttributes *attr = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    CGSize exampleSize = CGSizeMake(layoutAttributes.size.width, 0);
    CGSize preferredSize = [self.contentView systemLayoutSizeFittingSize:exampleSize withHorizontalFittingPriority:UILayoutPriorityRequired verticalFittingPriority:1];
    attr.size = preferredSize;
    return attr;
}

@end
