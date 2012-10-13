//
//  PPPSelectCardsViewController.m
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-13-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import "PPPSelectCardsViewController.h"

#import "PPPMainViewController.h"
#import "PPPCardCollection.h"

@interface PPPSelectCardsViewController ()

@end

@implementation PPPSelectCardsViewController

#pragma mark Property methods

- (NSArray *)presetCards {
    if (!_presetCards) {
        _presetCards = @[@"TH JH QC QD QS QH KH AH 2S 6S",
                         @"2H 2S 3H 3S 3C 2D 3D 6C 9C TH",
                         @"2H 2S 3H 3S 3C 2D 9C 3D 6C TH",
                         @"2H AD 5H AC 7H AH 6H 9H 4H 3C",
                         @"AC 2D 9C 3S KD 5S 4D KS AS 4C",
                         @"KS AH 2H 3C 4H KC 2C TC 2D AS",
                         @"AH 2C 9S AD 3C QH KS JS JD KD",
                         @"6C 9C 8C 2D 7C 2H TC 4C 9S AH",
                         @"3D 5S 2H QD TD 6S KH 9H AD QH"];
    }
    
    return _presetCards;
}

#pragma mark -
#pragma mark UITableViewDataSource protocol methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.presetCards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cardsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSString *cards = [self.presetCards objectAtIndex:indexPath.row];
    cell.textLabel.text = cards;
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate protocol methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    PPPCardCollection *deck = [[PPPCardCollection alloc] initWithString:cell.textLabel.text];
    
    if (deck) {
        PPPMainViewController *mainController = (PPPMainViewController *)self.navigationController.presentingViewController;
        [mainController setNewDeck:deck];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
