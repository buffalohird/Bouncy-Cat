//
//  RootViewController.m
//  Game
//
//  Created by Buffalo Hird on 12/4/11.
//  Copyright (c) 2011 Harvard University. All rights reserved.
//

#import "AppSpecificValues.h"

#import "RootViewController.h"

#import "GameViewController.h"




//Defines Hertz constant for acceleration
#define accelerometerFrequency (1.0f / 60.0f) // 60HZ


@implementation RootViewController 


@synthesize gameButton;
@synthesize gamecenterButton;
@synthesize rootBackground;
@synthesize rootBackgroundView;
@synthesize accelerometer;
@synthesize water;
@synthesize waterView;
@synthesize gameCenterManager;
@synthesize currentLeaderBoard;







- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}




-(void) startAccelerometer {
    accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = self;
    accelerometer.updateInterval = accelerometerFrequency;
}
    
-(void) stopAccelerometer {
    accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = nil;
}

//rotates the water below (for mostly eye-candy) if the screen-rotation is over a certain threshold (this won't work after playing any games but isn't an easy fix without subclassing.  It really just is fun eye-candy so we're considering it sufficient as is
-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    if(acceleration.x > 0.01 || acceleration.x < -0.01)
    {
        //the rotation is based off of acceleration + pi inputed into an arctan curve
        CGFloat rotation = -(atan2(acceleration.x, acceleration.y) + M_PI);
        // Dampens the values for better fluidity
        float div = 100 / (2 * M_PI);
        rotation = (int)(rotation * div) / div;
    
        // when rotating to the left, we don't want the water to pass a certain angle
        if(rotation > -3.14 && rotation < 0)
        {
            if(rotation < -0.20)
            {
                rotation = -0.20;
            }
        }
    
    
        // when rotating to the right, we don't want the water to pass this same angle
        if(rotation > -6.28 && rotation < -3.14)
        {
            if(rotation > -(2*M_PI) +0.20)
            {
                rotation = -(2*M_PI) +0.20;
            
            }
        }
    
        //animate the rotation of the water
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration: 1/60];
        waterView.transform = CGAffineTransformMakeRotation(rotation);
        [UIView commitAnimations];
    }
}


- (IBAction)showLeaderboard:(id)sender {

    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL) 
	{
		leaderboardController.category = self.currentLeaderBoard;
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self; 
		[self presentModalViewController: leaderboardController animated: YES];
	}

}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[self dismissModalViewControllerAnimated: YES];
	[viewController release];
}


//sends the player to the game
- (IBAction)gameView:(id)sender {
    
    [self stopAccelerometer];
    GameViewController *viewController = [[GameViewController alloc] initWithNibName: nil bundle: nil];
    [self presentModalViewController:viewController animated:YES];
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentLeaderBoard= kLeaderboardID;
	
    self.gameCenterManager= [[GameCenterManager alloc] init];
    [self.gameCenterManager setDelegate: self];
    [self.gameCenterManager authenticateLocalUser];
    



    [self.gameCenterManager reportScore: 16 forCategory: self.currentLeaderBoard];
    
    //start the accelerometer
    [self startAccelerometer];
    
    
    
       
    // set the background 
	rootBackground = [UIImage imageNamed: @"background.png"];
    rootBackgroundView = [[UIImageView alloc] initWithImage:rootBackground];
    rootBackgroundView.frame = CGRectMake(0, 0, 320, 480);
    [self.view insertSubview: rootBackgroundView belowSubview:gameButton];
    
    // set the water background
    water = [UIImage imageNamed:@"water.png"];
    waterView = [[UIImageView alloc] initWithImage:water];
    waterView.frame = CGRectMake(-82, 400, 520, 200);
    waterView.alpha = 0.60;
    [self.view insertSubview: waterView aboveSubview: gamecenterButton];
    [waterView release];

                                              
    // Do any additional setup after loading the view from its nib.
}




- (void)viewDidUnload
{
    [super viewDidUnload];
    
    
    [self startAccelerometer];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
