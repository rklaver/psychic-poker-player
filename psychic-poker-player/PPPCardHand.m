//
//  PPPCardHand.m
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-07-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import "PPPCardHand.h"

#import "PPPCard.h"
#import "PPPCardDeck.h"

#pragma mark Constants

#define kNumberOfCardsInHand 5

@implementation PPPCardHand

#pragma mark Instance methods

- (PPPCard *)replaceCardAtIndexByCardFromDeck:(NSUInteger)index {
    if (!self.deck || index >= self.cards.count) {
        return nil;
    }
    
    PPPCard *card = [self.deck draw];

    if (card) {
        [self.cards replaceObjectAtIndex:index withObject:card];
    }

    return card;
}

#pragma mark -
#pragma mark PPPCardCollection overridden methods

- (id)initWithCards:(NSMutableArray *)cards {
    self = [super initWithCards:cards];
    
    if (self) {
        if (self.cards.count != kNumberOfCardsInHand) {
            self = nil;
        }
    }
    
    return self;
}

@end
