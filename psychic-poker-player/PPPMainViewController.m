//
//  PPPMainViewController.m
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-06-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import "PPPMainViewController.h"

#import "PPPCardCollection.h"
#import "PPPCardHand.h"
#import "PPPSolver.h"

@implementation PPPMainViewController

#pragma mark Instance methods

- (IBAction)selectCardsButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"selectCards" sender:self];
}

- (IBAction)playButtonPressed:(UIBarButtonItem *)sender {
    PPPSolver *solver = [[PPPSolver alloc] initWithDeck:self.deck hand:self.hand];
    
    PPPCardHand *bestHand = [solver bestHandIn5CardDrawPokerGame];
    self.bestCategoryLabel.text = [PPPCardHand nameOfCategory:bestHand.highestCategory];
    
    self.playButton.enabled = NO;
}

- (void)setNewDeck:(PPPCardCollection *)deck {
    if (deck.cards.count >= 10) {
        NSMutableArray *handCards = [[NSMutableArray alloc] initWithCapacity:5];
        for (int i = 0; i < 5; i++) {
            [handCards addObject:[deck removeFirstCard]];
        }
        
        self.deck = deck;
        self.hand = [[PPPCardHand alloc] initWithCards:handCards];
        
        self.playButton.enabled = YES;
        self.bestCategoryLabel.text = nil;
    }
}

#pragma mark -
#pragma mark UIViewController overridden methods

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"greenfelt"]];
}

- (void)viewDidUnload {
    [self setPlayButton:nil];
    [self setBestCategoryLabel:nil];
    
    [super viewDidUnload];
}

@end
