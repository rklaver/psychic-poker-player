//
//  PPPSolver.h
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-08-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPPCardCollection;
@class PPPCardHand;

@interface PPPSolver : NSObject

@property (nonatomic, retain) PPPCardCollection *deck;
@property (nonatomic, retain) PPPCardHand *hand;

- (id)initWithDeck:(PPPCardCollection *)deck hand:(PPPCardHand *)hand;
- (PPPCardHand *)bestHandIn5CardDrawPokerGame;

@end
