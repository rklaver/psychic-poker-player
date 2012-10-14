//
//  PPPCardCollection.m
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-07-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import "PPPCardCollection.h"

#import "PPPCard.h"

#pragma mark Hidden interface

@interface PPPCardCollection ()

@property (nonatomic, strong) NSMutableArray *mutableCards;

@end

#pragma mark -

@implementation PPPCardCollection

#pragma mark Property methods

// Return an immutable copy of the internal mutable array of cards
- (NSArray *)cards {
    return [NSArray arrayWithArray:self.mutableCards];
}

#pragma mark KVO Class methods

// Have the cards property depend on mutableCards in order for KVO to work
+ (NSSet *)keyPathsForValuesAffectingCards {
    return [NSSet setWithObject:@"mutableCards"];
}

#pragma mark Instance methods

// This is the designated initializer
- (id)initWithCards:(NSArray *)cards {
    self = [super init];
    
    if (self) {
        self.mutableCards = [cards mutableCopy];
    }
    
    return self;
}


// Split a string by spaces and parse each component as a card, filtering out non-matching strings
- (id)initWithString:(NSString *)string {
    NSArray *cardStrings = [string componentsSeparatedByString:@" "];
    NSArray *cardStringsFiltered = [cardStrings filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedString, NSDictionary *bindings) {
        return evaluatedString.length > 0;
    }]];
    
    NSMutableArray *cards = [[NSMutableArray alloc] initWithCapacity:cardStringsFiltered.count];
    for (NSString *cardString in cardStringsFiltered) {
        PPPCard *card = [[PPPCard alloc] initWithString:cardString];
        if (card) {
            [cards addObject:card];
        }
    }
    
    return [self initWithCards:cards];
}

// Remove the first card in the selection of cards, e.g. as drawing the first card from a deck
- (PPPCard *)removeFirstCard {
    if ([self.mutableCards count] > 0) {
        PPPCard *card = self.mutableCards[0];
        [self removeObjectFromMutableCardsAtIndex:0];
        
        return card;
    }
    
    return nil;
}

// Replace a card in the sequence of cards with another one, e.g. replacing a card in a hand
// Note that this is KVO compliant
- (void)replaceCardAtIndex:(NSUInteger)index withCard:(PPPCard *)card {    
    if (card) {
        [self replaceObjectInMutableCardsAtIndex:index withObject:card];
    }
}

#pragma mark KVO instance methods

// These methods support KVO for the mutableCards and indirectly the cards property
- (void)insertObject:(PPPCard *)card inMutableCardsAtIndex:(NSUInteger)index {
    [self.mutableCards insertObject:card atIndex:index];
}

- (void)removeObjectFromMutableCardsAtIndex:(NSUInteger)index {
    [self.mutableCards removeObjectAtIndex:index];
}

- (void)replaceObjectInMutableCardsAtIndex:(NSUInteger)index withObject:(PPPCard *)card {
    [self.mutableCards replaceObjectAtIndex:index withObject:card];
}

#pragma mark -
#pragma mark NSObject overridden methods

// Init with no cards
- (id)init {
    return [self initWithCards:[NSArray array]];
}

#pragma mark -
#pragma mark NSObject protocol methods

// Implement copying
- (id)copyWithZone:(NSZone *)zone {
    PPPCardCollection *collection = [self.class allocWithZone:zone];
    collection.mutableCards = [self.mutableCards mutableCopyWithZone:zone];
    
    return collection;
}

#pragma mark -
#pragma mark NSObject protocol methods

// Description of the collection of cards by a series of 2-character strings
- (NSString *)description {
    NSArray *descriptions = [self.mutableCards valueForKey:@"description"];
    return [descriptions componentsJoinedByString:@" "];
}

@end
