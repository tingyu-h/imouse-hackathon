//
//  ViewController.h
//  iMouse
//
//  Created by Cyrus Huang on 4/10/15.
//  Copyright (c) 2015 CHSYTH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController : UIViewController <NSStreamDelegate, UITableViewDelegate> {
    
    // client variables
    UIView			*mainView;
    NSInputStream	*inputStream;
    NSOutputStream	*outputStream;
    UITextField		*xDeltaField;
    UITextField		*yDeltaField;
    NSMutableArray	*messages;
    
    // imu variables
    double currentMaxAccelX;
    double currentMaxAccelY;
    double currentMaxAccelZ;
    double currentMaxRotX;
    double currentMaxRotY;
    double currentMaxRotZ;
}

// client properties
@property (nonatomic, retain) IBOutlet UIView *mainView;

@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;

@property (nonatomic, retain) IBOutlet UITextField	*xDeltaField;
@property (nonatomic, retain) IBOutlet UITextField	*yDeltaField;

@property (nonatomic, retain) NSMutableArray *messages;

// imu properties
@property (strong, nonatomic) IBOutlet UILabel *accX;
@property (strong, nonatomic) IBOutlet UILabel *accY;
@property (strong, nonatomic) IBOutlet UILabel *accZ;

@property (strong, nonatomic) IBOutlet UILabel *maxAccX;
@property (strong, nonatomic) IBOutlet UILabel *maxAccY;
@property (strong, nonatomic) IBOutlet UILabel *maxAccZ;

@property (strong, nonatomic) IBOutlet UILabel *rotX;
@property (strong, nonatomic) IBOutlet UILabel *rotY;
@property (strong, nonatomic) IBOutlet UILabel *rotZ;

@property (strong, nonatomic) IBOutlet UILabel *maxRotX;
@property (strong, nonatomic) IBOutlet UILabel *maxRotY;
@property (strong, nonatomic) IBOutlet UILabel *maxRotZ;

@property (strong, nonatomic) CMMotionManager *motionManager;


- (IBAction) sendMove;
- (IBAction) sendLeft;
- (IBAction) sendRight;
- (void) initNetworkCommunication;
- (void) messageReceived:(NSString *)message;

- (IBAction)resetMaxValues:(id)sender;

@end

