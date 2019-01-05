//
//  ViewController.h
//  CQ
//
//  Created by Mazerlodge on 11/9/12.
//  Copyright (c) 2012 Mazerlodge. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WRAP_POINT 34

@interface ViewController : UIViewController {
        
    UITextField *txtInput;
    UITextView *txtPanel;
    
    NSString *rawPhrase;
    NSMutableString *translatedPhrase;
    NSMutableDictionary *tDict; // translation array
    
}

@property (nonatomic, retain) IBOutlet UITextField *txtInput;
@property (nonatomic, retain) IBOutlet UITextView *txtPanel;

- (IBAction)go:(id)sender;
- (IBAction)showUsage:(id)sender;
- (IBAction)setPhrase:(id)sender;
- (IBAction)showDistribution:(id)sender;
- (IBAction)showPhrase:(id)sender;
- (IBAction)closeKeyboard:(id)sender;

@end
