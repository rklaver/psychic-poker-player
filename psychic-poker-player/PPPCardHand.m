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

static NSDictionary *categoryNames;

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

// Property that represents the highest category this hand contains
// Use a cached value to prevent doing the computation more than once
- (PPPCardHandCategory)highestCategory {
    if (self.cachedHighestCategory == PPPCardHandCategoryInvalid) {
        self.cachedHighestCategory = [self determineHighestCategory];
    }
    
    return self.cachedHighestCategory;
}

#pragma mark Class methods

// Class method to translate the category enum value to a string
+ (NSString *)nameOfCategory:(PPPCardHandCategory)category {
    if (!categoryNames) {
        categoryNames = @{@(PPPCardHandCategoryNoPair): @"High card",
                          @(PPPCardHandCategoryOnePair): @"One pair",
                          @(PPPCardHandCategoryTwoPair): @"Two pair",
                          @(PPPCardHandCategoryThreeOfAKind): @"Three of a kind",
                          @(PPPCardHandCategoryStraight): @"Straight",
                          @(PPPCardHandCategoryFlush): @"Flush",
                          @(PPPCardHandCategoryFullHouse): @"Full house",
                          @(PPPCardHandCategoryFourOfAKind): @"Four of a kind",
                          @(PPPCardHandCategoryStraightFlush): @"Straight flush"};
    }
    
    return categoryNames[@(category)];
}

#pragma mark Instance methods

// Compare this hand to antoher hand, both in terms of category and any
// secondary comparison parameters for that category, such as highest card
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

// Internal helper method to determine if an ordered array of cards for a sequence for a straight
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

// Internal method that actually determines the category of this hand
// It will also populate an internal array that is used to compare this hand
// to other hands that have the same highest category
- (PPPCardHandCategory)determineHighestCategory {
    BOOL cardsAreOfSameSuit = NO;
    NSArray *cardsInSequence = nil;
    
    NSArray *cards = self.cards;
    PPPCard *firstCard = cards[0];
    
    // First, determine if all the cards are of the same suit,
    // for a flush or straight flush
    NSArray *cardsOfSameSuit = [cards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PPPCard *evaluatedCard, NSDictionary *bindings) {
        return evaluatedCard.suit == firstCard.suit;
    }]];
    
    if (cardsOfSameSuit.count == kNumberOfCardsInHand) {
        cardsAreOfSameSuit = YES;
    }
    
    // Then, determine if all the cards in this hand are sequential
    // for a straight or straight flush, either with aces low or high
    NSArray *cardsSortedAcesHigh = [cards sortedArrayUsingSelector:@selector(compareWithAcesHigh:)];
    if ([self.class cardsAreSequential:cardsSortedAcesHigh]) {
        cardsInSequence = cardsSortedAcesHigh;
    } else {
        NSArray *cardsSortedAcesLow = [cards sortedArrayUsingSelector:@selector(compareWithAcesLow:)];
        if ([self.class cardsAreSequential:cardsSortedAcesLow]) {
            cardsInSequence = cardsSortedAcesLow;
        }
    }
    
    // If there is a sequence, save that sequence to the internal array
    // and save the category, either straight or a straight flush
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
    
    // If there is no sequence but the cards are of the same suit,
    // this is a flush.
    if (cardsAreOfSameSuit) {
        [self setComparisonCardsToReverseSortedCards:cards];
        
        return PPPCardHandCategoryFlush;
    }
    
    // For each card number, count how many times it occurs in the hand
    NSUInteger cardNumberCounts[PPPCardNumberMax] = {0};
    for (PPPCard *card in cards) {
        cardNumberCounts[card.number]++;
    }
    
    // Reverse the mapping of card count, make a dictionary keyed by the count and
    // has as its value and array of card numbers
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
    
    // See if we have four-in-a-row
    NSArray *cardNumbersForFourInARow = cardNumberCountsToNumbersMapping[@(4)];
    if (cardNumbersForFourInARow) {
        PPPCardNumber cardNumberForFourInARow = ((NSNumber *)cardNumbersForFourInARow[0]).unsignedIntegerValue;
        
        // Populate the internal comparison array, put the four-in-a-row cards in front
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
    
    // See if we have three-in-a-row or a full house
    NSArray *cardNumbersForThreeInARow = cardNumberCountsToNumbersMapping[@(3)];
    if (cardNumbersForThreeInARow) {
        PPPCardNumber cardNumberForThreeInARow = ((NSNumber *)cardNumbersForThreeInARow[0]).unsignedIntegerValue;
        
        // If there is also a pair, this is a full house
        NSArray *cardNumbersForFullHousePair = cardNumberCountsToNumbersMapping[@(2)];
        
        // Populate the internal comparison array, put the three-in-a-row cards in front,
        // sort the other two cards in descending order
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
    
    // See if we have two-pair or one-pair
    NSArray *cardNumbersForPairs = cardNumberCountsToNumbersMapping[@(2)];
    if (cardNumbersForPairs) {
        PPPCardNumber cardNumberForFirstPair = ((NSNumber *)cardNumbersForPairs[0]).unsignedIntegerValue;
        
        if (cardNumbersForPairs.count > 1) {
            // This means we have two pair
            PPPCardNumber cardNumberForSecondPair = ((NSNumber *)cardNumbersForPairs[1]).unsignedIntegerValue;
            
            // Populate the internal comparison array, put the higest ranking pair first,
            // then the other pair, then the remaining card
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
        
        // Populate the internal comparison array, put the pair first
        // Sort the rest in descending order
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
    
    // If we got here, that means we have no pair, sort the cards with highest cards first
    [self setComparisonCardsToReverseSortedCards:cards];
    
    return PPPCardHandCategoryNoPair;
}

// Helper method that sets the internal comparison array
// to all cards ordered high to low, with aces high
- (void)setComparisonCardsToReverseSortedCards:(NSArray *)cards; {
    self.sortedComparisonCards = [cards mutableCopy];
    NSSortDescriptor *reverseAcesHighSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(compareWithAcesHigh:)];
    [self.sortedComparisonCards sortUsingDescriptors:[NSArray arrayWithObject:reverseAcesHighSortDescriptor]];
}

#pragma mark -
#pragma mark PPPCardCollection overridden methods

// Only accept a collection of 5 cards as a hand
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

// Disallow this method from the superclass
- (PPPCard *)removeFirstCard {
    return nil;
}

#pragma mark -
#pragma mark NSKeyValueObserving protocol methods

// Invalidate the cached properties whenever the collection of cards in this hand changes
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

// Only remove this class as observer if we were observing in the first place
- (void)dealloc {
    if (_initialized) {
        [self removeObserver:self forKeyPath:@"cards"];
    }
}

@end
