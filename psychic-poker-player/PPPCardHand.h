//
//  PPPCardHand.h
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-07-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import "PPPCardCollection.h"

@class PPPCardDeck;
@class PPPCard;

@interface PPPCardHand : PPPCardCollection

@property (nonatomic, strong) PPPCardDeck *deck;

- (PPPCard *)replaceCardAtIndexByCardFromDeck:(NSUInteger)index;

@end
