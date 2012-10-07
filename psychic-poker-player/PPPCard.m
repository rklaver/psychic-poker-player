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

@implementation PPPCard

#pragma mark Instance methods

- (id)initWithNumber:(PPPCardNumber)number suit:(PPPCardSuit)suit {
    self = [super init];
    
    if (self) {
        self.number = number;
        self.suit = suit;
    }
    
    return self;
}

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

- (NSString *)name {
    NSString *numberName = kCardNumberNames[@(self.number)];
    NSString *suitName = kCardSuitNames[@(self.suit)];
    
    if (numberName && suitName) {
        return [NSString stringWithFormat:@"%@ of %@", numberName, suitName];
    }
    
    return @"Invalid card";
}

#pragma mark -
#pragma mark NSObject overridden methods

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

- (id)init {
    return [self initWithNumber:PPPCardNumberInvalid suit:PPPCardSuitInvalid];
}

- (NSString *)description {
    NSString *numberString = kCardNumberInverseStringMapping[@(self.number)];
    NSString *suitString = kCardSuitInverseStringMapping[@(self.suit)];
    
    if (numberString && suitString) {
        return [NSString stringWithFormat:@"%@%@", numberString, suitString];
    }
    
    return @"XX";
}

@end
