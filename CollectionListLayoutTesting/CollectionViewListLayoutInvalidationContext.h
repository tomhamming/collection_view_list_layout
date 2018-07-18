//
//  CollectionViewListLayoutInvalidationContext.h
//  CollectionListLayoutTesting
//
//  Created by Hamming, Tom on 7/18/18.
//  Copyright © 2018 Olive Tree Bible Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewListLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext

@property (strong) UICollectionViewLayoutAttributes *updatedAttributes;

@end
