//
//  PPPSelectCardsViewController.h
//  psychic-poker-player
//
//  Created by Ruud Klaver on 10-13-2012.
//  Copyright (c) 2012 Ruud Klaver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPPSelectCardsViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *presetCards;

- (IBAction)manualEntryPressed:(UIBarButtonItem *)sender;

@end
