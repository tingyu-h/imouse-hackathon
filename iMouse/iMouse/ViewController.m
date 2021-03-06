//
//  ViewController.m
//  iMouse
//
//  Created by Cyrus Huang on 4/10/15.
//  Copyright (c) 2015 CHSYTH. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize mainView;
@synthesize inputStream, outputStream;
@synthesize xDeltaField, yDeltaField;
@synthesize messages;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initNetworkCommunication];
    
    xDeltaField.text = @"0";
    yDeltaField.text = @"0";
    messages = [[NSMutableArray alloc] init];
    
    
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    currentMaxAccelZ = 0;
    
    currentMaxRotX = 0;
    currentMaxRotY = 0;
    currentMaxRotZ = 0;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .08;
    self.motionManager.gyroUpdateInterval = .05;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        [self outputRotationData:gyroData.rotationRate];
                                    }];
    
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    
    double xAccel = acceleration.x*1000;
    double yAccel = acceleration.y*1000;
    double zAccel = acceleration.z*1000;
    

    self.accX.text = [NSString stringWithFormat:@" %.2f",xAccel];
    
    // NSLog(self.accX.text);
    if(fabs(acceleration.x) > fabs(currentMaxAccelX))
    {
        currentMaxAccelX = acceleration.x;
    }
    self.accY.text = [NSString stringWithFormat:@" %.2f",yAccel];
    //NSLog(@"y: ", self.accY.text);
    if(fabs(acceleration.y) > fabs(currentMaxAccelY))
    {
        currentMaxAccelY = acceleration.y;
    }
    self.accZ.text = [NSString stringWithFormat:@" %.2f",zAccel];
    //NSLog(@"z: ", self.accZ.text);
    if(fabs(acceleration.z) > fabs(currentMaxAccelZ))
    {
        currentMaxAccelZ = acceleration.z;
    }
    
    NSString* xDelta = @"0";
    NSString* yDelta = @"0";
    
    if (( fabs(xAccel) > 200) || (( -850 < zAccel ) && ( zAccel < 0 )))
    {
        
        // If zAccel is negative, device is facing up
        // Going left if xAccel is positive
    
        double xScale = (acceleration.x * 10) * (acceleration.x * 10) * acceleration.x;
        
        xDelta = [@((int) xScale) stringValue];
        
    }
    
    if (( fabs(yAccel) > 200) || (( -850 < zAccel ) && ( zAccel < 0 )))
    {
        
        // If zAccel is negative, device is facing up
        // Going up if yAccel is negative
        
        double  yScale = (acceleration.y * 10) * (acceleration.y * 10) * (acceleration.y * 10);
        
        yDelta = [@((int) yScale) stringValue];
        
    }
    
    if (fabs(acceleration.x) > 0.2 || fabs(acceleration.y) > 0.2)
    {
        [self moveCursorWithX:xDelta andY:yDelta];
    }
    
    self.maxAccX.text = [NSString stringWithFormat:@" %.2f",currentMaxAccelX];
    self.maxAccY.text = [NSString stringWithFormat:@" %.2f",currentMaxAccelY];
    self.maxAccZ.text = [NSString stringWithFormat:@" %.2f",currentMaxAccelZ];
    
    
}
-(void)outputRotationData:(CMRotationRate)rotation
{
    
    self.rotX.text = [NSString stringWithFormat:@" %.2fr/s",rotation.x];
    //NSLog(self.rotX.text);
    if(fabs(rotation.x) > fabs(currentMaxRotX))
    {
        currentMaxRotX = rotation.x;
    }
    self.rotY.text = [NSString stringWithFormat:@" %.2fr/s",rotation.y];
    if(fabs(rotation.y) > fabs(currentMaxRotY))
    {
        currentMaxRotY = rotation.y;
    }
    self.rotZ.text = [NSString stringWithFormat:@" %.2fr/s",rotation.z];
    if(fabs(rotation.z) > fabs(currentMaxRotZ))
    {
        currentMaxRotZ = rotation.z;
    }
    
    // left click if z-rot positive
    // right click if z-rot negative
    
    if (rotation.z > 3) {
        [self clickLeft];
    } else if (rotation.z < -3) {
        [self clickRight];
    }
    
    self.maxRotX.text = [NSString stringWithFormat:@" %.2f",currentMaxRotX];
    self.maxRotY.text = [NSString stringWithFormat:@" %.2f",currentMaxRotY];
    self.maxRotZ.text = [NSString stringWithFormat:@" %.2f",currentMaxRotZ];
}

- (IBAction)resetMaxValues:(id)sender {
    
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    currentMaxAccelZ = 0;
    
    currentMaxRotX = 0;
    currentMaxRotY = 0;
    currentMaxRotZ = 0;
    
}

- (void) initNetworkCommunication {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"IPAddress", 80, &readStream, &writeStream);
    
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    
}

- (void) moveCursorWithX: (NSString*) xStr andY: (NSString*) yStr{
    
    NSString *response  = [NSString stringWithFormat:@"0,0,%@,%@,", xStr, yStr];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
}


// send move cursor command
- (IBAction) sendMove {
    
    NSLog(@"move command is sent with: %@,%@", xDeltaField.text, yDeltaField.text);
    [self moveCursorWithX:xDeltaField.text andY:yDeltaField.text];
    
    xDeltaField.text = @"0";
    yDeltaField.text = @"0";
}

// send left click command
- (IBAction) sendLeft {
    
    NSLog(@"Left command is sent.");
    
    [self clickLeft];
}

- (void) clickLeft {
    NSString *response  = [NSString stringWithFormat:@"1,0,0,0,"];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
}

// send right click command
- (IBAction) sendRight {
    
    NSLog(@"Right command is sent.");
    
    [self clickRight];
}

- (void) clickRight {
    NSString *response  = [NSString stringWithFormat:@"0,1,0,0,"];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
}


- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    NSLog(@"stream event %lu", (unsigned long)streamEvent);
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
        case NSStreamEventHasBytesAvailable:
            
            if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            
                            NSLog(@"server said: %@", output);
                            
                        }
                    }
                }
            }
            break;
            
            
        case NSStreamEventErrorOccurred:
            
            NSLog(@"Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            //[theStream release];
            theStream = nil;
            
            break;
        default:
            NSLog(@"Unknown event");
    }
    
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
