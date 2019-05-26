//
//  ViewController.m
//  CQ
//
//  Created by Mazerlodge on 11/9/12.
//  Copyright (c) 2012 Mazerlodge. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize txtInput;
@synthesize txtPanel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)go:(id)sender {
    // Input s/b in one of the formats specified in the showUsage method.
    
    [txtInput resignFirstResponder];
    
    NSString *input = txtInput.text;

    // check for 'help' keyword
    if (([input compare:@"?"] == NSOrderedSame)
        || ([input compare:@"help"] == NSOrderedSame)) {
        [self showUsage:nil];
        return;
    }

    // check for 'distro' keyword
    if ([input compare:@"distro"] == NSOrderedSame) {
        [self showDistribution:nil];
        return;
    }

    // check for 'save' keyword
    if ([input compare:@"save"] == NSOrderedSame) {
        [self doSave];
        return;
    }

    // check for 'load' keyword
    if ([input compare:@"load"] == NSOrderedSame) {
        [self doLoad];
        return;
    }

    // check for 'phrase' keyword
    if ([input compare:@"phrase"] == NSOrderedSame) {
        [self showPhrase:nil];
        return;
    }
    
    // check for 'set' keyword
    if ([input compare:@"set"] == NSOrderedSame) {
        [self setPhrase:sender];
        return;
    }
    
    [self processTranslationInput:input];

}

- (void) processTranslationInput: (NSString *) input {
    
    
    // split on equals sign
    NSArray *parts = [input componentsSeparatedByString:@"="];

	// if parts < 2 bail w/ error
    if ([parts count] != 2) {
        // Alert user translation not understood.
        NSString *title = @"Unable to Translate";
        NSString *caption = @"Use 'A=b' or '^AB=cd' or 'A= ' (space, to clear translation).";
		
		UIAlertController *uac = [UIAlertController alertControllerWithTitle:title
																	 message:caption
															  preferredStyle:UIAlertControllerStyleAlert];
		
		// Create the OK button and attach it to the alert controller.
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		[uac addAction:defaultAction];

		[self presentViewController:uac animated:YES completion:nil];
		
        return;
    }

	NSString *from = [parts objectAtIndex:0];
	NSString *to = [parts objectAtIndex:1];
	
    // Check for multi-character input
    if ([input characterAtIndex:0] == '^') {
        // process multi-char translation input
        
        // skip the carat and process remaining translations
        for (int idx=0; idx<[to length]; idx++) {
            
            // Note use idx+1 for 'From Char' to skip carat.
            NSString *fromChar = [[NSString alloc] initWithFormat:@"%c",[from characterAtIndex:idx+1]];
            NSString *toChar = [[NSString alloc] initWithFormat:@"%c",[to characterAtIndex:idx]];
            
            [self storeTranslationFrom:fromChar To:toChar];
            
        }
        
    }
    else {
        // process single char translation input
        [self storeTranslationFrom:from To:to];
        
    }

    [self applyTranslation];

}

- (IBAction)showUsage:(id)sender {
    
    NSArray *commands = [[NSArray alloc] initWithObjects:@"? or help - show this info.",
                         @"set - set phrase to output contents.",
                         @"distro - show letter distribution.",
                         @"save - save phrase and trans table.",
                         @"load - load phrase and trans table.",
                         @"phrase - show the phrase.",
                         @"A=b - add trans table entry.",
                         @"A=_ (space) - remove entry for A.",
                         @"^ABC=def - create multiple entries.",
                         nil];
    
    NSMutableString *msg = [[NSMutableString alloc] initWithString:@"Commands:\n"];
    for (int x=0; x<commands.count; x++) {
        [msg appendFormat:@"%@\n", [commands objectAtIndex:x]];
    }
    
    txtPanel.text = msg;

}

- (NSMutableString *) getTransTableAsString {
    // Get trans table translation to string ^ABC=def format.
    
    NSMutableString *transString = [[NSMutableString alloc] initWithString:@"^"];
    NSMutableString *keysList = [[NSMutableString alloc] initWithCapacity:26];
    NSMutableString *valsList = [[NSMutableString alloc] initWithCapacity:26];
    
    for (NSString *aKey in tDict.keyEnumerator) {
        [keysList appendString:aKey];
        [valsList appendString:[tDict valueForKey:aKey]];
        
    }
    
    [transString appendFormat:@"%@=%@", keysList, valsList];
    
    return transString;
    
}

- (void) doSave {

    // Just testing writing to a plist...
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Just curious, what is in paths?
    NSString *aPath = [paths objectAtIndex:0];
    NSString *fName = [aPath stringByAppendingPathComponent:@"CQData.plist"];
    
    NSArray *saveData = [[NSArray alloc] initWithObjects:rawPhrase, [self getTransTableAsString], nil];
    
    
    //[paths writeToFile:fName atomically:YES];
    //[rawPhrase writeToFile:fName atomically:YES encoding:NSASCIIStringEncoding error:NULL];
    [saveData writeToFile:fName atomically:YES];
    
    
    NSString *msg = [[NSString alloc] initWithFormat:@"Phrase Stored.\npathCount=%lu\npath=%@",
                     (unsigned long)[paths count], aPath];
    txtPanel.text = msg;

}

- (void) doLoad {

    txtPanel.text = @"Load not yet implemented.";
    
    // Just testing writing to a plist...
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *aPath = [paths objectAtIndex:0];
    NSString *fName = [aPath stringByAppendingPathComponent:@"CQData.plist"];
    NSArray *loadData = [[NSArray alloc] initWithContentsOfFile:fName];
    
    // Load data must contain two entries; phrase and trans table.
    if (loadData.count < 2) {
        return;
    }
    
    NSMutableString *dmsg = [[NSMutableString alloc] initWithFormat:@"Phrase: %@\n TransTable:%@\n", loadData[0], loadData[1]];
    txtPanel.text = dmsg;
    
    txtPanel.text = loadData[0];
    [self setPhrase:nil];
    [self processTranslationInput:loadData[1]];

}

- (IBAction) showPhrase:(id)sender  {
    
    [self applyTranslation];
    
}

- (void) applyTranslation {
    
    NSString *specialChars = @".-, '\":;0123456789$!?";
    translatedPhrase = [[NSMutableString alloc] init];
    
    if ([rawPhrase length] == 0) {
        txtPanel.text = @"No phrase loaded.";
        return;
    }
    
    // walk rawPhrase, applying translations
    for (int idx=0; idx<[rawPhrase length]; idx++) {
        NSString *rawChar = [[NSString alloc] initWithFormat:@"%c",[rawPhrase characterAtIndex:idx]];
        
        // get translation (if one exists)
        if ([tDict objectForKey:rawChar] == nil) {
            bool bUsedSpecialChar = NO;
            // if the rawChar is a special char, pass it to the output
            for (int s=0; s<[specialChars length]; s++) {
                NSString *specChar = [[NSString alloc] initWithFormat:@"%c",[specialChars characterAtIndex:s]];
                if ([rawChar compare:specChar] == NSOrderedSame) {
                    [translatedPhrase appendFormat:@"%@", rawChar];
                    bUsedSpecialChar = YES;
                }
            }
            
            // no translation, put space in translated Phrase
            if (!bUsedSpecialChar)
                [translatedPhrase appendFormat:@" "];
        }
        else {
            // get translation and apply it to the translatedPhrase
            NSString *transChar = [tDict objectForKey:rawChar];
            [translatedPhrase appendFormat:@"%@", transChar];
            
        }
    }
    
    // Hook here to generate stacked output, send output to txtPanel 
    txtPanel.text = [self getOutputLine];
    
}

- (NSString *) getOutputLine {
    
    NSMutableString *rval = [[NSMutableString alloc] initWithCapacity:[rawPhrase length]];
    NSUInteger startPos = 0;
    
    while (startPos < [rawPhrase length]) {
        NSUInteger segmentEnd = [self getBreakpointForStartPos:startPos];
        NSRange segRange = NSMakeRange(startPos, segmentEnd-startPos);
        
        // Add the translated segment to the output
        NSString *temp = [translatedPhrase substringWithRange:segRange];
        NSMutableString *segment = [[NSMutableString alloc] initWithFormat:@"[%@",temp];
        
        // Pad with spaces if segment < WRAP_POINT
        if ([segment length] < WRAP_POINT)
            for (int p=0; p<(WRAP_POINT-segRange.length); p++)
                [segment appendString:@" "];
        // Add a space to keep text view from auto wrapping
        [segment appendString:@"] "];
        //NSLog(@"gOL() ln135: trans segment %@", segment);
        [rval appendString:segment];
        
        // Add the raw segment to the output
        temp = [rawPhrase substringWithRange:segRange];
        segment = [[NSMutableString alloc] initWithFormat:@"[%@",temp];

        // Pad with spaces if segment < WRAP_POINT
        if ([segment length] < WRAP_POINT)
            for (int p=0; p<(WRAP_POINT-segRange.length); p++)
                [segment appendString:@" "];
        // Add a space to keep text view from auto wrapping
        [segment appendString:@"] "];
        //NSLog(@"gOL() ln142: raw segment %@", segment);
        [rval appendString:segment];
        
        // Add a blank line to output between segments
        /*
        segment = [[NSMutableString alloc] initWithString:@"["];
        for (int p=0; p<WRAP_POINT; p++)
            [segment appendString:@" "];
        // Add a space to keep text view from auto wrapping
        [segment appendString:@"] "];
        [rval appendString:segment];
        */
        
        // Advance the start pos to the end of this segment
        startPos += segmentEnd-startPos;
        
    }

    return rval;

}

- (NSUInteger) getBreakpointForStartPos: (NSUInteger) startPos {
    
    NSUInteger rval = startPos + WRAP_POINT;
    
    // if rval is bigger than the phrase back down to the end of phrase
    if (rval > [rawPhrase length])
        return [rawPhrase length];
    
    // Find the last whitespace at or before the end of the max segment
    while ([rawPhrase characterAtIndex:rval] != ' ') {
        rval--;
    }
    
    return rval;
    
}

- (void) storeTranslationFrom: (NSString *) fromChar To:(NSString *) toChar {
    
    // see if the translate TO letter is already in use
    bool bToLetterInUse = false;
    for (NSString *k in tDict) {
        NSString *s = [tDict objectForKey:k];
        if ([toChar compare:s] == NSOrderedSame) {
            bToLetterInUse = true;
            break;
        }
    }
    
    if (bToLetterInUse) {
        // Alert user
        NSString *title = [[NSString alloc] initWithFormat: @"Letter In Use"];
        NSString *caption = [[NSString alloc] initWithFormat:@"The target letter '%@' is in use.", toChar];
		
		UIAlertController *uac = [UIAlertController alertControllerWithTitle:title
																	 message:caption
															  preferredStyle:UIAlertControllerStyleAlert];

		// Create the OK button and attach it to the alert controller.
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		[uac addAction:defaultAction];
		
		[self presentViewController:uac animated:YES completion:nil];

        return;
    }

    // Determine if the from letter already existed
    if ([tDict objectForKey:fromChar] == nil) {
        
        // If target is not a space, add the translation to the dictionary
        if ([toChar compare:@" "] != NSOrderedSame)
            [tDict setValue:toChar forKey:fromChar];
        
    }
    else {        
        // Replace the existing translation, unless the translation
        //   is to a space, then just remove the translation
        [tDict removeObjectForKey:fromChar];
        
        if ([toChar compare:@" "] != NSOrderedSame) {
            // replace translation
            [tDict setValue:toChar forKey:fromChar];
            
        }
        
    }

}

- (IBAction)setPhrase:(id)sender {

    [txtPanel resignFirstResponder];

    // copy contents of txtPanel into phrase
    rawPhrase = txtPanel.text;
    
    // clear translation array
    tDict = [[NSMutableDictionary alloc] initWithCapacity:26];
    
    [self showPhrase:nil];
    
}

- (IBAction)showDistribution:(id)sender {
    // Display the character distribution of rawPhrase.
    
    NSMutableDictionary *letterDistro = [[NSMutableDictionary alloc] initWithCapacity:26];
    
    // Build a letter usage dictionary containing count of usage for each letter
    for (int x=0; x<rawPhrase.length; x++) {
        char currChar = [rawPhrase characterAtIndex:x];
        NSNumber *can = [[NSNumber alloc] initWithChar:currChar];
        NSNumber *usageCount = [[NSNumber alloc] initWithInt:0];
        
        if ([letterDistro objectForKey:can] == nil) {
            // Set usage count to zero.
            [letterDistro setObject:usageCount forKey:can];
        }
        else {
            // Increment usage count.
            usageCount = [letterDistro objectForKey:can];
            usageCount = [[NSNumber alloc] initWithInt:usageCount.intValue+1];
            [letterDistro setObject:usageCount forKey:can];
            
        } // if else...
        
    } // for x...
    
    NSMutableString *msg = [[NSMutableString alloc] initWithString:@"Distribution:\n"];
	NSArray *sortedKeys = [self sortTheKeys:[letterDistro allKeys]];
	
	for (NSNumber *aKey in sortedKeys)
		NSLog(@"%@",aKey);
    
    for (NSNumber *aKey in sortedKeys) {
        [msg appendFormat:@"%c=%d\n", aKey.intValue, [[letterDistro objectForKey:aKey] intValue]];
        
    }
    [msg appendString:@"** end distro. **"];
    
    txtPanel.text = msg;
    
    
}

- (NSArray *) sortTheKeys: (NSArray *) unsortedKeys {
	
	// An array of NSNumbers
	NSMutableArray *rval = [[NSMutableArray alloc] initWithCapacity:[unsortedKeys count]];
	
	NSNumber *MAX_CHAR = [[NSNumber alloc] initWithChar:127];
	NSNumber *minNum = MAX_CHAR;
	NSNumber *maxOutVal = [[NSNumber alloc] initWithChar:0];
	bool bDone = false;
	
	while (!bDone) {
		// find minVal in input that is greater than maxVal in output
		for (NSNumber *aNum in unsortedKeys)
			if (([minNum compare:aNum] == NSOrderedDescending)
				&& ([maxOutVal compare:aNum] == NSOrderedAscending))
				minNum = aNum;
		
		// put the found value in the output array
		[rval addObject:minNum];
		maxOutVal = minNum;
		minNum = MAX_CHAR;
		
		if ([rval count] == [unsortedKeys count])
			bDone = true;
	}
	
	return rval;
}


- (IBAction)closeKeyboard:(id)sender {
    
    [txtPanel resignFirstResponder];
    [txtInput resignFirstResponder];
    
    NSLog(@"Close Keyboard triggered.");
}


@end
