//
//  ViewController.m
//  CollectionListLayoutTesting
//
//  Created by Hamming, Tom on 7/18/18.
//  Copyright © 2018 Olive Tree Bible Software. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewListLayout.h"
#import "ListCollectionViewCell.h"

@interface ViewController ()

@end

static int numRows = 50;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CollectionViewListLayout *layout = [[CollectionViewListLayout alloc]init];
    layout.estimatedRowHeight = 80;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.view addSubview:collectionView];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [collectionView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [collectionView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [collectionView registerClass:[ListCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    collectionView.delegate = self;
    collectionView.dataSource = self;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return numRows;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"%i", (int)indexPath.item];
    return cell;
}

@end
