//
//  PPPMainViewController.h
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-06-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPPCardCollection;
@class PPPCardHand;

@interface PPPMainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (nonatomic, strong) PPPCardCollection *deck;
@property (nonatomic, strong) PPPCardHand *hand;
@property (weak, nonatomic) IBOutlet UILabel *bestCategoryLabel;

- (IBAction)selectCardsButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)playButtonPressed:(UIBarButtonItem *)sender;
- (void)setNewDeck:(PPPCardCollection *)deck;

@end
