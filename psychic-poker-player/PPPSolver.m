//
//  PPPSolver.m
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-08-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import "PPPSolver.h"

#import "PPPCardCollection.h"
#import "PPPCardHand.h"

#pragma mark Hidden interface

@interface PPPSolver ()

+ (NSArray *)possiblePlaysByExchangingNumberOfCards:(NSUInteger)numCards totalCards:(NSUInteger)totalCards;

@end

#pragma mark -

@implementation PPPSolver

#pragma mark Instance methods

// Designated initializer 
- (id)initWithDeck:(PPPCardCollection *)deck hand:(PPPCardHand *)hand {
    self = [super init];
    
    if (self) {
        self.deck = deck;
        self.hand = hand;
    }
    
    return self;
}

// Go through all possible plays in the game and return both the the array of plays that is
// best and the hand resulting from it.
- (NSArray *)bestPlayIn5CardDrawPokerGameWithResultingHand:(PPPCardHand **)bestHand {
    *bestHand = nil;
    NSArray *bestPlay;
    
    NSMutableArray *allPossiblePlays = [[NSMutableArray alloc] init];
    for (NSUInteger numCards = 0; numCards <= 5; numCards++) {
        [allPossiblePlays addObjectsFromArray:[self.class possiblePlaysByExchangingNumberOfCards:numCards totalCards:5]];
    }
    
    for (NSArray *cardsToExchange in allPossiblePlays) {
        PPPCardHand *playHand = [self.hand copy];
        PPPCardCollection *playDeck = [self.deck copy];
        
        for (NSNumber *cardToExchange in cardsToExchange) {
            [playHand replaceCardAtIndex:cardToExchange.unsignedIntegerValue withCard:[playDeck removeFirstCard]];
        }
        
        if (*bestHand == nil || [*bestHand compare:playHand] == NSOrderedAscending) {
            *bestHand = playHand;
            bestPlay = cardsToExchange;
        }
    }
    
    return bestPlay;
}

#pragma mark Hidden class methods

// Returns an array of arrays, containing all possible plays for exchanging numCards number of cards
+ (NSArray *)possiblePlaysByExchangingNumberOfCards:(NSUInteger)numCards totalCards:(NSUInteger)totalCards {
    NSMutableArray *plays = [[NSMutableArray alloc] init];
    
    if (numCards <= totalCards) {
        if (numCards > 0) {
            // This is a recursively called block, which has as parameters the "path" of exchanged cards
            // up to now and the number of cards that still need to be removed
            void (^__block nextIterationOfFindingIndexCombinations)(NSArray *, NSUInteger) = ^(NSArray *path, NSUInteger cardsToRemove) {
                for (NSUInteger index = 0; index < totalCards - cardsToRemove + 1; index++) {
                    NSNumber *indexNumber = @(index);
                    
                    if (path.count > 0 && [[path lastObject] compare:indexNumber] != NSOrderedAscending) {
                        continue;
                    }
                    
                    NSArray *newPath = [path arrayByAddingObject:indexNumber];
                    
                    if (cardsToRemove > 1) {
                        nextIterationOfFindingIndexCombinations(newPath, cardsToRemove - 1);
                    } else {
                        [plays addObject:newPath];
                    }
                }
            };
            
            nextIterationOfFindingIndexCombinations([NSArray array], numCards);
        } else {
            [plays addObject:[NSArray array]];
        }
    }
    
    return plays;
}

@end
