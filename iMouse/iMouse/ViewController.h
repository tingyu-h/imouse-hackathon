//
//  ViewController.h
//  iMouse
//
//  Created by Cyrus Huang on 4/10/15.
//  Copyright (c) 2015 CHSYTH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSStreamDelegate, UITableViewDelegate> {
    
    UIView			*mainView;
    NSInputStream	*inputStream;
    NSOutputStream	*outputStream;
    UITextField		*xDeltaField;
    UITextField		*yDeltaField;
    NSMutableArray	*messages;
    
}


@property (nonatomic, retain) IBOutlet UIView *mainView;

@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;

@property (nonatomic, retain) IBOutlet UITextField	*xDeltaField;
@property (nonatomic, retain) IBOutlet UITextField	*yDeltaField;

@property (nonatomic, retain) NSMutableArray *messages;

- (IBAction) sendMove;
- (IBAction) sendLeft;
- (IBAction) sendRight;
- (void) initNetworkCommunication;
- (IBAction) sendMessage;
- (void) messageReceived:(NSString *)message;

@end

