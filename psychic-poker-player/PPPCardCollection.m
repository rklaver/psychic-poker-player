//
//  PPPCardCollection.m
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-07-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import "PPPCardCollection.h"

#import "PPPCard.h"

@implementation PPPCardCollection

#pragma mark Instance methods

- (id)initWithCards:(NSMutableArray *)cards {
    self = [super init];
    
    if (self) {
        self.cards = cards;
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

#pragma mark -
#pragma mark NSObject overridden methods

- (id)init {
    return [self initWithCards:[NSMutableArray arrayWithCapacity:0]];
}

- (NSString *)description {
    NSArray *descriptions = [self.cards valueForKey:@"description"];
    return [descriptions componentsJoinedByString:@" "];
}

@end
