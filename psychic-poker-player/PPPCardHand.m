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

#pragma mark Hidden interface

@interface PPPCardHand () {
    BOOL _initialized;
}

@property (nonatomic, assign) PPPCardHandCategory cachedHighestCategory;
@property (nonatomic, strong) NSMutableArray *sortedComparisonCards;

+ (BOOL)cardsAreSequential:(NSArray *)cards;
- (PPPCardHandCategory)determineHighestCategory;
- (void)setComparisonCardsToReverseSortedCards:(NSArray *)cards;

@end

#pragma mark -

@implementation PPPCardHand

#pragma mark Property methods

- (PPPCardHandCategory)highestCategory {
    if (self.cachedHighestCategory == PPPCardHandCategoryInvalid) {
        self.cachedHighestCategory = [self determineHighestCategory];
    }
    
    return self.cachedHighestCategory;
}

#pragma mark Instance methods

- (NSComparisonResult)compare:(PPPCardHand *)otherHand {
    if (self.highestCategory < otherHand.highestCategory) {
        return NSOrderedAscending;
    }
    
    if (self.highestCategory > otherHand.highestCategory) {
        return NSOrderedDescending;
    }
    
    NSComparisonResult result = NSOrderedSame;

    for (NSUInteger i = 0; i < kNumberOfCardsInHand; i++) {
        PPPCard *card = self.sortedComparisonCards[i];
        PPPCard *otherCard = otherHand.sortedComparisonCards[i];
        result = [card compareWithAcesHigh:otherCard];
        
        if (result != NSOrderedSame) {
            break;
        }
    }

    return result;
}

#pragma mark Hidden class methods

+ (BOOL)cardsAreSequential:(NSArray *)cards {
    for (NSUInteger i = 0; i < cards.count - 1; i++) {
        PPPCard *currentCard = cards[i];
        PPPCard *nextCard = cards[i+1];
        
        if (![currentCard isSequentiallySucceededByCard:nextCard]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark Hidden instance methods

- (PPPCardHandCategory)determineHighestCategory {
    BOOL cardsAreOfSameSuit = NO;
    NSArray *cardsInSequence = nil;
    
    NSArray *cards = self.cards;
    PPPCard *firstCard = cards[0];
    
    NSArray *cardsOfSameSuit = [cards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PPPCard *evaluatedCard, NSDictionary *bindings) {
        return evaluatedCard.suit == firstCard.suit;
    }]];
    
    if (cardsOfSameSuit.count == kNumberOfCardsInHand) {
        cardsAreOfSameSuit = YES;
    }
    
    NSArray *cardsSortedAcesHigh = [cards sortedArrayUsingSelector:@selector(compareWithAcesHigh:)];
    if ([self.class cardsAreSequential:cardsSortedAcesHigh]) {
        cardsInSequence = cardsSortedAcesHigh;
    } else {
        NSArray *cardsSortedAcesLow = [cards sortedArrayUsingSelector:@selector(compareWithAcesLow:)];
        if ([self.class cardsAreSequential:cardsSortedAcesLow]) {
            cardsInSequence = cardsSortedAcesLow;
        }
    }
    
    if (cardsInSequence) {
        self.sortedComparisonCards = [NSMutableArray arrayWithCapacity:kNumberOfCardsInHand];
        for (PPPCard *card in [cardsInSequence reverseObjectEnumerator]) {
            [self.sortedComparisonCards addObject:card];
        }
        
        if (cardsAreOfSameSuit) {
            return PPPCardHandCategoryStraightFlush;
        } else {
            return PPPCardHandCategoryStraight;
        }
    }
    
    if (cardsAreOfSameSuit) {
        [self setComparisonCardsToReverseSortedCards:cards];
        
        return PPPCardHandCategoryFlush;
    }
    
    NSUInteger cardNumberCounts[PPPCardNumberMax] = {0};
    for (PPPCard *card in cards) {
        cardNumberCounts[card.number]++;
    }
    
    NSMutableDictionary *cardNumberCountsToNumbersMapping = [NSMutableDictionary dictionaryWithCapacity:kNumberOfCardsInHand];
    for (PPPCardNumber cardNumber = PPPCardNumberInvalid + 1; cardNumber < PPPCardNumberMax; cardNumber++) {
        NSNumber *cardNumberCount = @(cardNumberCounts[cardNumber]);
        if (cardNumberCount.unsignedIntegerValue > 1) {
            NSMutableArray *cardNumbers = cardNumberCountsToNumbersMapping[cardNumberCount];
            if (!cardNumbers) {
                cardNumbers = [NSMutableArray arrayWithCapacity:1];
                cardNumberCountsToNumbersMapping[cardNumberCount] = cardNumbers;
            }
            [cardNumbers addObject:@(cardNumber)];
        }
    }
    
    NSArray *cardNumbersForFourInARow = cardNumberCountsToNumbersMapping[@(4)];
    if (cardNumbersForFourInARow) {
        PPPCardNumber cardNumberForFourInARow = ((NSNumber *)cardNumbersForFourInARow[0]).unsignedIntegerValue;
        
        self.sortedComparisonCards = [NSMutableArray arrayWithCapacity:kNumberOfCardsInHand];
        for (PPPCard *card in cardsSortedAcesHigh) {
            if (card.number == cardNumberForFourInARow) {
                [self.sortedComparisonCards insertObject:card atIndex:0];
            } else {
                [self.sortedComparisonCards addObject:card];
            }
        }
        
        return PPPCardHandCategoryFourOfAKind;
    }
    
    NSArray *cardNumbersForThreeInARow = cardNumberCountsToNumbersMapping[@(3)];
    if (cardNumbersForThreeInARow) {
        PPPCardNumber cardNumberForThreeInARow = ((NSNumber *)cardNumbersForThreeInARow[0]).unsignedIntegerValue;
        
        NSArray *cardNumbersForFullHousePair = cardNumberCountsToNumbersMapping[@(2)];
        
        self.sortedComparisonCards = [NSMutableArray arrayWithCapacity:kNumberOfCardsInHand];
        for (PPPCard *card in cardsSortedAcesHigh) {
            if (card.number == cardNumberForThreeInARow) {
                [self.sortedComparisonCards insertObject:card atIndex:0];
            } else {
                [self.sortedComparisonCards addObject:card];
            }
        }
        
        if (cardNumbersForFullHousePair) {
            return PPPCardHandCategoryFullHouse;
        } else {
            return PPPCardHandCategoryThreeOfAKind;
        }
    }
    
    NSArray *cardNumbersForPairs = cardNumberCountsToNumbersMapping[@(2)];
    if (cardNumbersForPairs) {
        PPPCardNumber cardNumberForFirstPair = ((NSNumber *)cardNumbersForPairs[0]).unsignedIntegerValue;
        
        if (cardNumbersForPairs.count > 1) {
            PPPCardNumber cardNumberForSecondPair = ((NSNumber *)cardNumbersForPairs[1]).unsignedIntegerValue;
            
            self.sortedComparisonCards = [cards mutableCopy];
            [self.sortedComparisonCards sortUsingComparator:^NSComparisonResult(PPPCard *card, PPPCard *otherCard) {
                if (card.number != cardNumberForFirstPair && card.number != cardNumberForSecondPair) {
                    return NSOrderedDescending;
                } else if (otherCard.number != cardNumberForFirstPair && otherCard.number != cardNumberForSecondPair) {
                    return NSOrderedAscending;
                }
                
                return [otherCard compareWithAcesHigh:card];
            }];
            
            return PPPCardHandCategoryTwoPair;
        }
        
        self.sortedComparisonCards = [NSMutableArray arrayWithCapacity:kNumberOfCardsInHand];
        for (PPPCard *card in cardsSortedAcesHigh) {
            if (card.number == cardNumberForFirstPair) {
                [self.sortedComparisonCards insertObject:card atIndex:0];
            } else {
                [self.sortedComparisonCards addObject:card];
            }
        }
        
        return PPPCardHandCategoryOnePair;
    }
    
    [self setComparisonCardsToReverseSortedCards:cards];
    
    return PPPCardHandCategoryNoPair;
}

- (void)setComparisonCardsToReverseSortedCards:(NSArray *)cards; {
    self.sortedComparisonCards = [cards mutableCopy];
    NSSortDescriptor *reverseAcesHighSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(compareWithAcesHigh:)];
    [self.sortedComparisonCards sortUsingDescriptors:[NSArray arrayWithObject:reverseAcesHighSortDescriptor]];
}

#pragma mark -
#pragma mark PPPCardCollection overridden methods

- (id)initWithCards:(NSArray *)cards {
    if (cards.count == kNumberOfCardsInHand) {
        self = [super initWithCards:cards];
        
        if (self) {
            _initialized = YES;
            [self addObserver:self forKeyPath:@"cards" options:0 context:NULL];
        }
        
        return self;
    }
    
    return nil;
}

- (PPPCard *)removeFirstCard {
    return nil;
}

#pragma mark -
#pragma mark NSKeyValueObserving protocol methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self) {
        if ([keyPath isEqualToString:@"cards"]) {
            self.cachedHighestCategory = PPPCardHandCategoryInvalid;
            self.sortedComparisonCards = nil;
            return;
        }
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark -
#pragma mark NSObject overridden methods

- (void)dealloc {
    if (_initialized) {
        [self removeObserver:self forKeyPath:@"cards"];
    }
}

@end
