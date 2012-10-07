//
//  PPPCardHand.h
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-07-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import "PPPCardCollection.h"

typedef NS_ENUM(NSUInteger, PPPCardHandCategory) {
    PPPCardHandCategoryInvalid = 0,
    PPPCardHandCategoryNoPair,
    PPPCardHandCategoryOnePair,
    PPPCardHandCategoryTwoPair,
    PPPCardHandCategoryThreeOfAKind,
    PPPCardHandCategoryStraight,
    PPPCardHandCategoryFlush,
    PPPCardHandCategoryFullHouse,
    PPPCardHandCategoryFourOfAKind,
    PPPCardHandCategoryStraightFlush,
    PPPCardHandCategoryMax
};

@class PPPCard;

@interface PPPCardHand : PPPCardCollection

@property (nonatomic, readonly) PPPCardHandCategory highestCategory;

- (NSComparisonResult)compare:(PPPCardHand *)otherHand;

@end
