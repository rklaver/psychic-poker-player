//
//  PPPCardHand.m
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-07-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import "PPPCardHand.h"

#import "PPPCard.h"

#pragma mark Constants

#define kNumberOfCardsInHand 5

@implementation PPPCardHand

#pragma mark -
#pragma mark PPPCardCollection overridden methods

- (id)initWithCards:(NSArray *)cards {
    if (cards.count == kNumberOfCardsInHand) {
        return [super initWithCards:cards];
    }
    
    return nil;
}

@end
