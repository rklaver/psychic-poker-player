//
//  PPPCardDeck.h
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-07-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import "PPPCardCollection.h"

@class PPPCard;

@interface PPPCardDeck : PPPCardCollection

- (PPPCard *)draw;

@end
