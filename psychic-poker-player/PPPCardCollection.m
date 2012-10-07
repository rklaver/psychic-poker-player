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

@interface PPPCardCollection () {
    NSMutableArray *_cards;
}

@end

@implementation PPPCardCollection

#pragma mark Property methods

- (NSArray *)cards {
    return [NSArray arrayWithArray:_cards];
}

#pragma mark Instance methods

- (id)initWithCards:(NSArray *)cards {
    self = [super init];
    
    if (self) {
        _cards = [cards mutableCopy];
    }
    
    return self;
}

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

- (PPPCard *)removeFirstCard {
    if ([_cards count] > 0) {
        PPPCard *card = _cards[0];
        [_cards removeObjectAtIndex:0];
        
        return card;
    }
    
    return nil;
}

- (void)replaceCardAtIndex:(NSUInteger)index withCard:(PPPCard *)card {    
    if (card) {
        [_cards replaceObjectAtIndex:index withObject:card];
    }
}

#pragma mark -
#pragma mark NSObject overridden methods

- (id)init {
    return [self initWithCards:[NSArray array]];
}

#pragma mark -
#pragma mark NSObject protocol methods

- (NSString *)description {
    NSArray *descriptions = [_cards valueForKey:@"description"];
    return [descriptions componentsJoinedByString:@" "];
}

@end
