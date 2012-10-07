//
//  PPPCardCollection.h
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-07-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPPCard;

@interface PPPCardCollection : NSObject

@property (nonatomic, readonly) NSArray *cards;

- (id)initWithCards:(NSArray *)cards;
- (id)initWithString:(NSString *)string;
- (PPPCard *)removeFirstCard;
- (void)replaceCardAtIndex:(NSUInteger)index withCard:(PPPCard *)card;

@end
