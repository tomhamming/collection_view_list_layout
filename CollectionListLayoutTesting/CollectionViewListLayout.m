//
//  CollectionViewListLayout.m
//  BibleReader
//
//  Created by Hamming, Tom on 7/9/18.
//  Copyright © 2018 Olive Tree Bible Software. All rights reserved.
//

#import "CollectionViewListLayout.h"
#import "CollectionViewListLayoutInvalidationContext.h"

@interface CollectionViewListLayout ()
@property (retain) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *rowAttributes;
@property (retain) NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *headerAttributes;
@property CGFloat maxY;
@property (retain) NSNumber *inflightWidth;
@end

@implementation CollectionViewListLayout

-(id)init
{
    self = [super init];
    if (self)
    {
        self.rowAttributes = [NSMutableDictionary dictionary];
        self.headerAttributes = [NSMutableDictionary dictionary];
    }
    
    return self;
}

-(void)dealloc
{
    self.rowAttributes = nil;
    self.headerAttributes = nil;
}

+(Class)invalidationContextClass
{
    return [CollectionViewListLayoutInvalidationContext class];
}

-(CGFloat)width
{
    return (self.inflightWidth ? self.inflightWidth.floatValue : self.collectionView.bounds.size.width);
}

-(void)invalidateLayout
{
    NSLog(@"Invalidate everything");
    [super invalidateLayout];
    [self.rowAttributes removeAllObjects];
    [self.headerAttributes removeAllObjects];
}

-(void)invalidateLayoutWithContext:(CollectionViewListLayoutInvalidationContext *)context
{
    NSLog(@"Invalidate with context");
    
    UICollectionViewLayoutAttributes *rowAttr = [self.rowAttributes objectForKey:context.updatedAttributes.indexPath];
    rowAttr.size = CGSizeMake([self width], context.updatedAttributes.size.height);
    
    [super invalidateLayoutWithContext:context];
}

-(void)prepareLayout
{
    NSLog(@"Preparing layout");
    CGFloat currY = 0;
    NSInteger numSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    
    for (NSInteger s = 0; s < numSections; s++)
    {
        UICollectionViewLayoutAttributes *sectionAttr = [self.headerAttributes objectForKey:@(s)];
        
        if (!sectionAttr)
        {
            NSIndexPath *sectionPath = [NSIndexPath indexPathForItem:0 inSection:s];
            sectionAttr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:sectionPath];
            [self.headerAttributes setObject:sectionAttr forKey:@(s)];
        }
        
        sectionAttr.frame = CGRectMake(0, currY, [self width], self.headerHeight);
//        NSLog(@"%i: %.1f %.1f", (int)s, sectionAttr.frame.origin.y, sectionAttr.size.height);
        currY += sectionAttr.size.height;
        
        NSInteger numRows = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:s];
        for (NSInteger r = 0; r < numRows; r++)
        {
            NSIndexPath *rowPath = [NSIndexPath indexPathForItem:r inSection:s];
            UICollectionViewLayoutAttributes *rowAttr = [self.rowAttributes objectForKey:rowPath];
            if (!rowAttr)
            {
                rowAttr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:rowPath];
                rowAttr.frame = CGRectMake(0, currY, [self width], self.estimatedRowHeight);
                [self.rowAttributes setObject:rowAttr forKey:rowPath];
            }
            else
            {
                rowAttr.frame = CGRectMake(0, currY, [self width], rowAttr.size.height);
            }
            
//            NSLog(@"%i.%i: %.1f %.1f", (int)rowPath.section, (int)rowPath.item, rowAttr.frame.origin.y, rowAttr.size.height);
            
            currY += rowAttr.size.height;
        }
    }
    
    self.maxY = currY;
}

-(void)prepareForAnimatedBoundsChange:(CGRect)oldBounds
{
    [super prepareForAnimatedBoundsChange:oldBounds];
//    NSLog(@"Prepare for animated bounds");
    self.inflightWidth = @(self.collectionView.bounds.size.width);
}

-(void)finalizeAnimatedBoundsChange
{
    [super finalizeAnimatedBoundsChange];
//    NSLog(@"Finalize animated bounds");
    self.inflightWidth = nil;
}

-(CGSize)collectionViewContentSize
{
//    NSInteger numSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
//    CGFloat headerHeight = 0;
//    CGFloat rowHeight = 0;
//
//    for (NSInteger section = 0; section < numSections; section++)
//    {
//        UICollectionViewLayoutAttributes *headerAttr = [self.headerAttributes objectForKey:@(section)];
//        headerHeight += headerAttr.size.height;
//
//        NSInteger numRows = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];
//        for (NSInteger row = 0; row < numRows; row++)
//        {
//            NSIndexPath *path = [NSIndexPath indexPathForItem:row inSection:section];
//            UICollectionViewLayoutAttributes *rowAttr = [self.rowAttributes objectForKey:path];
//            rowHeight += rowAttr.size.height;
//        }
//    }
//
//    return CGSizeMake(self.collectionView.bounds.size.width, headerHeight + rowHeight);
    
    return CGSizeMake([self width], self.maxY);
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *result = [self.rowAttributes objectForKey:indexPath];
    return result;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    return [self.headerAttributes objectForKey:@(indexPath.section)];
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSLog(@"Attributes in rect %.1f to %.1f", rect.origin.y, CGRectGetMaxY(rect));
    NSMutableArray<UICollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    
    NSArray<UICollectionViewLayoutAttributes *> *attrs = [self.rowAttributes.allValues sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        UICollectionViewLayoutAttributes *a1 = (UICollectionViewLayoutAttributes *)obj1;
        UICollectionViewLayoutAttributes *a2 = (UICollectionViewLayoutAttributes *)obj2;
        if (a1.indexPath.item > a2.indexPath.item)
            return NSOrderedDescending;
        else if (a1.indexPath.item < a2.indexPath.item)
            return NSOrderedAscending;
        else
            return NSOrderedSame;
    }];
    for (UICollectionViewLayoutAttributes *attr in attrs)
    {
        if (CGRectIntersectsRect(attr.frame, rect))
        {
            [result addObject:attr];
            NSLog(@"Result row %i.%i (%.1f %.1f)", (int)attr.indexPath.section, (int)attr.indexPath.item, attr.frame.origin.y, attr.frame.size.height);
        }
    }
    
    for (UICollectionViewLayoutAttributes *attr in self.headerAttributes.allValues)
    {
        if (CGRectIntersectsRect(attr.frame, rect))
        {
            [result addObject:attr];
            NSLog(@"Result header %i (%.1f %.1f)", (int)attr.indexPath.section, attr.frame.origin.y, attr.frame.size.height);
        }
    }
    NSLog(@"(end rect call)");
    
    return result;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    BOOL result = newBounds.size.width != self.collectionView.bounds.size.width;
    return result;
}

-(UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds
{
    UICollectionViewLayoutInvalidationContext *result = [super invalidationContextForBoundsChange:newBounds];
    [result invalidateEverything];
    return result;
}

-(BOOL)shouldInvalidateLayoutForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes
{
    if (preferredAttributes.size.height != originalAttributes.size.height)
    {
        NSLog(@"Row change: %i.%i, %@ to %@", (int)preferredAttributes.indexPath.section, (int)preferredAttributes.indexPath.item, NSStringFromCGSize(originalAttributes.size), NSStringFromCGSize(preferredAttributes.size));
        return YES;
    }
    
    return NO;
}

-(UICollectionViewLayoutInvalidationContext *)invalidationContextForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes
{
    CollectionViewListLayoutInvalidationContext *result = (CollectionViewListLayoutInvalidationContext *)[super invalidationContextForPreferredLayoutAttributes:preferredAttributes withOriginalAttributes:originalAttributes];
    result.updatedAttributes = preferredAttributes;
    
    CGFloat heightDelta = preferredAttributes.size.height - originalAttributes.size.height;
    
    NSLog(@"Preferred attributes height delta %.1f", heightDelta);
    result.contentSizeAdjustment = CGSizeMake(0, heightDelta);
    return result;
}

@end
