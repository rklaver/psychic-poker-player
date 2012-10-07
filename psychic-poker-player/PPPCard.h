//
//  PPPCard.h
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-06-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PPPCardNumber) {
    PPPCardNumberTwo,
    PPPCardNumberThree,
    PPPCardNumberFour,
    PPPCardNumberFive,
    PPPCardNumberSix,
    PPPCardNumberSeven,
    PPPCardNumberEight,
    PPPCardNumberNine,
    PPPCardNumberTen,
    PPPCardNumberJack,
    PPPCardNumberQueen,
    PPPCardNumberKing,
    PPPCardNumberAce,
    PPPCardNumberInvalid
};

typedef NS_ENUM(NSUInteger, PPPCardSuit) {
    PPPCardSuitHearts,
    PPPCardSuitClubs,
    PPPCardSuitSpades,
    PPPCardSuitDiamonds,
    PPPCardSuitInvalid
};

@interface PPPCard : NSObject

@property (nonatomic, assign) PPPCardNumber number;
@property (nonatomic, assign) PPPCardSuit suit;

- (id)initWithNumber:(PPPCardNumber)number suit:(PPPCardSuit)suit;
- (id)initWithString:(NSString *)cardString;
- (NSString *)name;
- (NSComparisonResult)compareWithAcesLow:(PPPCard *)otherCard;
- (NSComparisonResult)compareWithAcesHigh:(PPPCard *)otherCard;
- (BOOL)isSequentiallySucceededByCard:(PPPCard *)otherCard;

@end
