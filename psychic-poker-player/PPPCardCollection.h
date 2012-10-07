//
//  PPPCardCollection.h
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-07-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPPCardCollection : NSObject

@property (nonatomic, strong) NSMutableArray *cards;

- (id)initWithCards:(NSMutableArray *)cards;
- (id)initWithString:(NSString *)string;

@end
