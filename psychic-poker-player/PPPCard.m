//
//  PPPCard.m
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-06-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import "PPPCard.h"

#pragma mark Constants

static NSRegularExpression *kCardStringRegexp;
static NSDictionary *kCardNumberStringMapping;
static NSDictionary *kCardSuitStringMapping;
static NSDictionary *kCardNumberInverseStringMapping;
static NSDictionary *kCardSuitInverseStringMapping;
static NSDictionary *kCardNumberNames;
static NSDictionary *kCardSuitNames;

#pragma mark -

@implementation PPPCard

#pragma mark Instance methods

// This is the designated initializer
- (id)initWithNumber:(PPPCardNumber)number suit:(PPPCardSuit)suit {
    self = [super init];
    
    if (self) {
        self.number = number;
        self.suit = suit;
    }
    
    return self;
}

// Parse a 2-character string using a regular expression
- (id)initWithString:(NSString *)cardString {
    NSTextCheckingResult *result = [kCardStringRegexp firstMatchInString:cardString options:0 range:NSMakeRange(0, [cardString length])];
    
    if (result) {
        NSString *numberString = [[cardString substringWithRange:[result rangeAtIndex:1]] uppercaseString];
        PPPCardNumber number = [(NSNumber *)kCardNumberStringMapping[numberString] unsignedIntegerValue];
        
        NSString *suitString = [[cardString substringWithRange:[result rangeAtIndex:2]] uppercaseString];
        PPPCardSuit suit = [(NSNumber *)kCardSuitStringMapping[suitString] unsignedIntegerValue];
        
        return [self initWithNumber:number suit:suit];
    }
    
    return nil;
}

// Represent the card as a human readable name
- (NSString *)name {
    NSString *numberName = kCardNumberNames[@(self.number)];
    NSString *suitName = kCardSuitNames[@(self.suit)];
    
    if (numberName && suitName) {
        return [NSString stringWithFormat:@"%@ of %@", numberName, suitName];
    }
    
    return @"Invalid card";
}

// Compare to another card, aces are low
- (NSComparisonResult)compareWithAcesLow:(PPPCard *)otherCard {
    if (self.number == PPPCardNumberAce || otherCard.number == PPPCardNumberAce) {
        if (otherCard.number != PPPCardNumberAce) {
            return NSOrderedAscending;
        }
        
        if (self.number != PPPCardNumberAce) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }
    
    return [self compareWithAcesHigh:otherCard];
}

// Compare to another card, aces are high
- (NSComparisonResult)compareWithAcesHigh:(PPPCard *)otherCard {
    if (self.number < otherCard.number) {
        return NSOrderedAscending;
    }
    
    if (self.number > otherCard.number) {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
}


// Check if another car is the next card in a sequence for a straight
- (BOOL)isSequentiallySucceededByCard:(PPPCard *)otherCard {
    if (self.number == PPPCardNumberAce) {
        return otherCard.number == PPPCardNumberTwo;
    }
    
    return otherCard.number == self.number + 1;
}

#pragma mark -
#pragma mark NSObject overridden methods

// When class is first used, initialize several mapping dictionarys for converting between enum values and strings
+ (void)initialize {
    kCardNumberStringMapping = @{@"2": @(PPPCardNumberTwo),
                                 @"3": @(PPPCardNumberThree),
                                 @"4": @(PPPCardNumberFour),
                                 @"5": @(PPPCardNumberFive),
                                 @"6": @(PPPCardNumberSix),
                                 @"7": @(PPPCardNumberSeven),
                                 @"8": @(PPPCardNumberEight),
                                 @"9": @(PPPCardNumberNine),
                                 @"T": @(PPPCardNumberTen),
                                 @"J": @(PPPCardNumberJack),
                                 @"Q": @(PPPCardNumberQueen),
                                 @"K": @(PPPCardNumberKing),
                                 @"A": @(PPPCardNumberAce)};
    
    kCardSuitStringMapping = @{@"H": @(PPPCardSuitHearts),
                               @"C": @(PPPCardSuitClubs),
                               @"S": @(PPPCardSuitSpades),
                               @"D": @(PPPCardSuitDiamonds)};
    
    NSMutableDictionary *numberInverseMapping = [[NSMutableDictionary alloc] initWithCapacity:[kCardNumberStringMapping count]];
    [kCardNumberStringMapping enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSNumber *value, BOOL *stop) {
        numberInverseMapping[value] = key;
    }];
    kCardNumberInverseStringMapping = numberInverseMapping;
    
    NSMutableDictionary *suitInverseMapping = [[NSMutableDictionary alloc] initWithCapacity:[kCardSuitStringMapping count]];
    [kCardSuitStringMapping enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSNumber *value, BOOL *stop) {
        suitInverseMapping[value] = key;
    }];
    kCardSuitInverseStringMapping = suitInverseMapping;
    
    kCardNumberNames = @{@(PPPCardNumberTwo): @"Two",
                         @(PPPCardNumberThree): @"Three",
                         @(PPPCardNumberFour): @"Four",
                         @(PPPCardNumberFive): @"Five",
                         @(PPPCardNumberSix): @"Six",
                         @(PPPCardNumberSeven): @"Seven",
                         @(PPPCardNumberEight): @"Eight",
                         @(PPPCardNumberNine): @"Nine",
                         @(PPPCardNumberTen): @"Ten",
                         @(PPPCardNumberJack): @"Jack",
                         @(PPPCardNumberQueen): @"Queen",
                         @(PPPCardNumberKing): @"King",
                         @(PPPCardNumberAce): @"Ace"};
    
    kCardSuitNames = @{@(PPPCardSuitHearts): @"Hearts",
                       @(PPPCardSuitClubs): @"Clubs",
                       @(PPPCardSuitSpades): @"Spades",
                       @(PPPCardSuitDiamonds): @"Diamonds"};
    
    NSError *regexpError = nil;

    NSString *numberStrings = [[kCardNumberStringMapping allKeys] componentsJoinedByString:@""];
    NSString *suitStrings = [[kCardSuitStringMapping allKeys] componentsJoinedByString:@""];
    NSString *regexpString = [NSString stringWithFormat:@"\\A([%@])([%@])\\z", numberStrings, suitStrings];
    kCardStringRegexp = [NSRegularExpression regularExpressionWithPattern:regexpString options:NSRegularExpressionCaseInsensitive error:&regexpError];
    
    NSAssert(!regexpError, @"Regular expression error");
}

// Initialize as an invalid card
- (id)init {
    return [self initWithNumber:PPPCardNumberInvalid suit:PPPCardSuitInvalid];
}

#pragma mark -
#pragma mark NSObject protocol methods

// Description of a PPPCard object as a 2-character string
- (NSString *)description {
    NSString *numberString = kCardNumberInverseStringMapping[@(self.number)];
    NSString *suitString = kCardSuitInverseStringMapping[@(self.suit)];
    
    if (numberString && suitString) {
        return [NSString stringWithFormat:@"%@%@", numberString, suitString];
    }
    
    return @"XX";
}

@end
