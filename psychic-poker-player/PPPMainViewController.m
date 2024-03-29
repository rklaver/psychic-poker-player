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
#import "PPPCard.h"

#pragma mark Constants

#define kCardAnimationDuration 0.5

@implementation PPPMainViewController

#pragma mark Instance methods

// Show the modal to have the user select the set of cards
- (IBAction)selectCardsButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"selectCards" sender:self];
}

// When the play button is pressed, solve the game for the given
// set of cards, then show this as an animation to the user,
// then show a text displaying the best hand category
- (IBAction)playButtonPressed:(UIBarButtonItem *)sender {
    PPPSolver *solver = [[PPPSolver alloc] initWithDeck:self.deck hand:self.hand];
    PPPCardHand *bestHand;
    
    NSArray *bestPlay = [solver bestPlayIn5CardDrawPokerGameWithResultingHand:&bestHand];
    
    NSArray *deckCards = self.deck.cards;
    NSUInteger index = 0;
    
    if (bestPlay.count > 0) {
        isAnimating = YES;
        self.selectCardsButton.enabled = NO;
    } else {
        self.bestCategoryLabel.text = [PPPCardHand nameOfCategory:bestHand.highestCategory];
    }
    
    for (NSNumber *cardToExchangeNumber in bestPlay) {
        NSUInteger cardToExchange = cardToExchangeNumber.unsignedIntegerValue;
        
        UIImageView *handImageView = self.handCardImages[cardToExchange];
        CGRect oldHandFrame = handImageView.frame;
        CGRect newHandFrame = CGRectMake(oldHandFrame.origin.x, self.view.frame.size.height, oldHandFrame.size.width, oldHandFrame.size.height);
        [UIView animateWithDuration:kCardAnimationDuration delay:kCardAnimationDuration*index*2 options:UIViewAnimationCurveEaseIn animations:^{
            handImageView.frame = newHandFrame;
        } completion:^(BOOL finished) {
            handImageView.image = nil;
            handImageView.frame = oldHandFrame;
        }];
        
        UIImageView *deckImageView = self.deckCardImages[index];
        CGRect oldDeckFrame = deckImageView.frame;
        [UIView animateWithDuration:kCardAnimationDuration delay:kCardAnimationDuration*index*2 + kCardAnimationDuration options:UIViewAnimationCurveEaseInOut animations:^{
            deckImageView.frame = oldHandFrame;
        } completion:^(BOOL finished) {
            deckImageView.image = nil;
            deckImageView.frame = oldDeckFrame;
            
            PPPCard *newCard = [deckCards objectAtIndex:index];
            handImageView.image = [UIImage imageNamed:[newCard description]];
            
            if (index == bestPlay.count - 1) {
                self.bestCategoryLabel.text = [PPPCardHand nameOfCategory:bestHand.highestCategory];
                
                isAnimating = NO;
                self.selectCardsButton.enabled = YES;
                
                // If the user rotated the device during the animation,
                // make sure the rotation actually happens now
                [UIViewController attemptRotationToDeviceOrientation];
            }
        }];

        index++;
    }
    
    self.playButton.enabled = NO;
}

// This method is called by the select cards controller,
// it will set up the deck and hand from a deck of 10 cards
- (void)setNewDeck:(PPPCardCollection *)deck {
    if ([deck cardCount] == 10) {
        NSMutableArray *handCards = [[NSMutableArray alloc] initWithCapacity:5];
        for (int i = 0; i < 5; i++) {
            [handCards addObject:[deck removeFirstCard]];
        }
        
        self.deck = deck;
        self.hand = [[PPPCardHand alloc] initWithCards:handCards];
        
        NSArray *deckCards = self.deck.cards;
        
        for (NSUInteger index = 0; index < 5; index++) {
            PPPCard *card = deckCards[index];
            UIImageView *imageView = self.deckCardImages[index];
            imageView.image = [UIImage imageNamed:[card description]];
            
            card = handCards[index];
            imageView = self.handCardImages[index];
            imageView.image = [UIImage imageNamed:[card description]];
        }
        
        self.playButton.enabled = YES;
        self.bestCategoryLabel.text = nil;
    }
}

#pragma mark -
#pragma mark UIViewController overridden methods

- (void)viewDidLoad {
    // For some reason the order within an outlet collection set in the storyboard
    // is not preserved, so order the objects by their x coordinates manually
    self.deckCardImages = [self.deckCardImages sortedArrayUsingComparator:^NSComparisonResult(UIImageView *view1, UIImageView *view2) {
        return [@(view1.frame.origin.x)compare:@(view2.frame.origin.x)];
    }];
    
    self.handCardImages = [self.handCardImages sortedArrayUsingComparator:^NSComparisonResult(UIImageView *view1, UIImageView *view2) {
        return [@(view1.frame.origin.x)compare:@(view2.frame.origin.x)];
    }];
}

// Disallow rotation when an animation is being performed,
// because the cards will end up in the wrong place.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (isAnimating) {
        return toInterfaceOrientation == self.interfaceOrientation;
    } else {
        return YES;
    }
}

- (void)viewDidUnload {
    [self setSelectCardsButton:nil];
    [self setPlayButton:nil];
    [self setBestCategoryLabel:nil];
    [self setDeckCardImages:nil];
    [self setHandCardImages:nil];
    
    [super viewDidUnload];
}

@end
