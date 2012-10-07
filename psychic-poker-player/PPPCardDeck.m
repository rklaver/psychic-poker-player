//
//  PPPCardDeck.m
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-07-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import "PPPCardDeck.h"

#import "PPPCard.h"

@implementation PPPCardDeck

#pragma mark Instance methods

- (PPPCard *)draw {
    if ([self.cards count] > 0) {
        PPPCard *card = self.cards[0];
        [self.cards removeObjectAtIndex:0];
        
        return card;
    }
    
    return nil;
}

@end
