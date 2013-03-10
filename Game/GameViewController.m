//
//  GameViewController.m
//  Game
//
//  Created by Buffalo Hird on 12/1/11.
//  Copyright (c) 2011 Harvard University. All rights reserved.
//
#import "AppSpecificValues.h"

#import "GameViewController.h"

#import "GameCenterManager.h"



//Defines Hertz constant for acceleration
#define accelerometerFrequency (1.0f / 60.0f) // 60HZ
#define accelerationConstant 9 // a multiplier applied to the accelerometer
#define gravityConstant 0.0011 // the a value in our vertical velocity equation
#define jumpY 2.75 // the Vo of our Vf equation
#define edgeConstant 30 //the required 'buffer-pixels' so that when the player is about to go off the screen, the app will recognize this before the sprite is partially out-of-view 
#define platformWidth 106 // width of platform
#define platformHeight 50 // height of platform
#define basePlayerY 470 //the ground level for the player (to be avoided for those who wish to get a high score)
#define playerWidth 60
#define playerHeight 60


@implementation GameViewController

@synthesize playerImage;
@synthesize platformImage;
@synthesize background;
@synthesize water;
@synthesize playerView;
@synthesize platformView;
@synthesize backgroundView;
@synthesize waterView;
@synthesize delta;
@synthesize menuButton;
@synthesize gravityTimer;
@synthesize platformTimer;
@synthesize movementTimer;
@synthesize scoreLabel;
@synthesize accelerometer;
@synthesize gameWon;
@synthesize levelLabel;
@synthesize gameCenterManager;
@synthesize currentLeaderBoard;
@synthesize currentScore;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
        
    platformArray = [[NSMutableArray alloc] initWithCapacity:5];
                     
    //self.currentLeaderBoard= kLeaderboardID;
                     
    //self.gameCenterManager= [[GameCenterManager alloc] init];
    //[self.gameCenterManager setDelegate: self];
    //[self.gameCenterManager authenticateLocalUser];

    //resets the game counter, score, initial gravity velocity, platform counter, and  to avoid any sort of garbage values
    gameWon = NO;
    arrayCounter = 0;
    currentScore = 0;
    velocityY = 0;
    platformCounter = 0;
    deltaYPlatform = 0;
    level = 1;
    
    // set the background 
	background = [UIImage imageNamed:@"background.png"];
    backgroundView = [[UIImageView alloc] initWithImage:background];
    backgroundView.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview: backgroundView];
    [backgroundView release];
    
    //creates a menu button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [button addTarget:self 
                action:@selector(menuAlert:)
                forControlEvents:UIControlEventTouchUpInside];
                [button setTitle:@"Pause" forState:UIControlStateNormal];
                button.frame = CGRectMake(10.0, 420.0, 30.0, 30.0);
    
    [self.view insertSubview:button aboveSubview: backgroundView];

    
	// load the sprites/images
    platformImage = [UIImage imageNamed:@"platform.png"];
    playerImage = [UIImage imageNamed:@"player.png"];
    
    //creates the score label
    scoreLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 10, 142, 25)];
    scoreLabel.opaque = YES;
    scoreLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"score.png"]];
    scoreLabel.alpha = 0.5;
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.text = [NSString stringWithFormat: @"  Score: %d", currentScore];
    
    [self.view insertSubview:scoreLabel aboveSubview: button];
    [scoreLabel release];
    
    //creates the level label
    levelLabel = [[UILabel alloc] initWithFrame: CGRectMake(168, 10, 142, 25)];
    levelLabel.opaque = YES;
    levelLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"score.png"]];
    levelLabel.alpha = 0.5;
    levelLabel.textColor = [UIColor whiteColor];
    levelLabel.text = [NSString stringWithFormat: @"   Level %d", level];
    
    [self.view insertSubview:levelLabel aboveSubview: scoreLabel];
    [levelLabel release];


    
    [self playerReset];
    
    //set the water
    water = [UIImage imageNamed:@"water.png"];
    waterView = [[UIImageView alloc] initWithImage: water];
    waterView.frame = CGRectMake(-82, 400, 520, 200);
    waterView.alpha = 0.60;
    [self.view insertSubview: waterView aboveSubview: scoreLabel];
    [waterView release];
 
    //creates a mutable array which will hold the spawned objects

    
    //creates an instructions alert
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Instructions:"
                          message:@"To move, simply tilt the screen left and right.  You must hit the platforms to bounce and remain out of the water as long as possible. Remember, cats HATE water! \n Good Luck!"
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Start", nil];
    [alert show];
    [alert release];
    
}

- (void) submitScore
{
	if(self.currentScore > 0)
	{
		[self.gameCenterManager reportScore: self.currentScore forCategory: self.currentLeaderBoard];

	}
}

-(void)playerReset {
    
    if(playerView)
    {
        playerView.hidden = TRUE;
    }
    //allocs a view of this player
    playerView = [[UIImageView alloc] initWithImage:playerImage];
	playerView.frame = CGRectMake(130, 258, 60, 60);
	playerView.alpha = 1.00;
	[self.view insertSubview:playerView belowSubview: scoreLabel];
    [playerView release];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // we halt all timers when we pause, so if the player unpauses we must restart the acceleration of gravity if the player is off the ground, and the platform timer
    
    if(buttonIndex == 0)
    {
        if(gameWon == YES)
        {
            [self menuView:(id)alertView];
        }
        else
        {
            
            if(playerView.center.y < basePlayerY && currentScore != 0)
            {
                [self startGravity];
            }
            // unhide the active platforms
            for(UIPlatformView *platform in platformArray)
            {
                platform.alpha = 0.80;
            }
            platformTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
            movementTimer = [NSTimer scheduledTimerWithTimeInterval:(0.01) target: self selector: @selector(onUpdatePlatforms) userInfo: nil repeats: YES];
            [self startAccelerometer];
            [self platformTimer];
            [self movementTimer];
        }
        
    }
    
    //the other button returns you to the main menu
    if(buttonIndex == 1)
    {
        [self menuView:(id)alertView];
    }

}

-(void)onUpdatePlatforms {
    
    //moves the platforms down at a slowly increasing rate that maxes out at double the original rate
    for(UIPlatformView *platform in platformArray)
    {
        deltaYPlatform = 1.5 + (platformCounter * 0.01);
        if(deltaYPlatform > 4)
        {
            deltaYPlatform = 4;
        }
        
        //if on the screen the platform moves regularly 
        if(platform.center.y + deltaYPlatform < (480 - platformHeight/2))
        {    
            platform.center = CGPointMake(platform.center.x, (platform.center.y + deltaYPlatform));
        }
        //otherwise it is moved to 60 pixels below the screen while waiting for removal
        else if(platform.center.y + deltaYPlatform >= (480 - platformHeight/2))
        {
            
            platform.center = CGPointMake(platform.center.x, 540);
            
        }
        
    }
    
    // after a certain number of platforms (increasing each level), the level has been completed
    if([platformArray count] >= 10 + (5 * level))
    {
        [self levelComplete];        
    }
    
}

-(void) levelComplete {
    
    //we stop the accelerometer from sending data and stop the timers/ remove all objects when the game has been paused
    [self stopAccelerometer];
    
    
    
    [platformTimer invalidate];
    platformTimer = nil;
    
    
    [gravityTimer invalidate];
    gravityTimer = nil;
    
    [movementTimer invalidate];
    movementTimer = nil;
    
    //we hide all current platforms
    for(UIPlatformView *platform in platformArray)
    {
        platform.alpha = 0.00;
        
    }
    //we remove all current platforms
    [platformArray removeAllObjects];
    
    //alerts the player that the level has been completed
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:[NSString stringWithFormat:@"Level %d Completel!", level]
                          message:nil
                          delegate:self
                          cancelButtonTitle:@"Next Level"
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    //reset the player position and level number for the next level
    [self playerReset];
    
    //adjusts the level data
    level++;
    levelLabel.text = [NSString stringWithFormat: @"  Level %d", level];
    arrayCounter = 0;

}

//every iteration of the gravity timer we accelerate by 1t in the equation v = 1/2 a t^2 (the a is a constant applied later)
-(void)onGravityTimer {
    
    gravityCounter++;
    gravity = 4.9 * (gravityCounter * gravityCounter);
    
}

//this method convienently allows us to begin accelerating gravity when the player leaves a surface
-(void)startGravity {
    
    gravityTimer = [NSTimer scheduledTimerWithTimeInterval:(0.1) target:self selector:@selector(onGravityTimer) userInfo:nil repeats:YES];
    [self gravityTimer];
}


//this method allows us to convienently halt the acceleration due to gravity when the player touches a surface
-(void)stopGravity {
    

    [gravityTimer invalidate];
    gravityTimer = nil; 
    
    gravityCounter = 0;

}


//this method supplies a Vo value to the equation Vf = Vo + 1/2at^2 so that the player 'jumps' from a platform
-(void)jump {
    velocityY = jumpY;
    
    //we do not want the player to move upward if they are already at the top of the screen
    if ((playerView.center.y <= (0 + edgeConstant)) && (delta.y > 0))
    {
        playerView.center=CGPointMake(playerView.center.x,playerView.center.y);
        
    }
    else
    {
        playerView.center=CGPointMake(playerView.center.x,playerView.center.y - delta.y);
    }
}


-(void) menuAlert:(id)sender {
    
    
    //we stop the accelerometer from sending data and stop the timers/ remove all objects when the game has been paused
    [self stopAccelerometer];
    

    
    [platformTimer invalidate];
    platformTimer = nil;
    
    
    [gravityTimer invalidate];
    gravityTimer = nil;
    
    [movementTimer invalidate];
    movementTimer = nil;
    
    
    //we hide the current platforms so that we can resume them, not just restart the timer
    for(UIPlatformView *platform in platformArray)
     {
         platform.alpha = 0.00;
     }


    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Paused"
                          message:nil
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Resume", @"Main Menu", nil];
    [alert show];
    [alert release];
    
    
}


//when the main menu is called, we first stop the accelerometer and then dismiss the game view
-(void)menuView:(id)sender {
    
    [self stopAccelerometer];
    [self dismissModalViewControllerAnimated: YES];
    
}

// this method convienently allows us to easily toggle reception of the accelerometer data on
-(void) startAccelerometer {
    accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = self;
    accelerometer.updateInterval = accelerometerFrequency;
}

// this method convienently allows us to easily toggle reception of the accelerometer data off
-(void) stopAccelerometer {
    accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = nil;
}

//Recieves the data from the accelerometer and creates a change in x based on the acceleration of the x-axis (times a constant)
-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    delta.x = acceleration.x * accelerationConstant;
    
    //here is our Vf = Vo + 1/2at^2, which has been modified with constants that give a desired rate to vertical acceleration
    delta.y = velocityY - (gravityConstant * gravity);

    // this defines a terminal velocity
    if (delta.y < -6.5)
    {
        delta.y = -6.5;
    }
    
    //if the player is at an edge of the screen and tries to move off of it, the player will not move further off the screen
    if(((playerView.center.x <= (0 + edgeConstant)) && (delta.x < 0))|| ((playerView.center.x >= 320 - (edgeConstant)) && (delta.x > 0)))
    {
        if(playerView.center.y >= basePlayerY || [platformArray count] < 4)
        {
            //if on the ground, we must stop gravity if it is still running
            if(gravityTimer != nil)
            {
                [self stopGravity];
            }
            //on the ground, we move left/right but there is no vertical acceleration acting upon the player
            playerView.center = CGPointMake(playerView.center.x, playerView.center.y);
        }
    //if in the air
        else
        {
            //if not on the ground and the game has started, we must start gravity if it is not already running
            if(gravityCounter == 0)
            {
                [self startGravity];
            }
            
            //corner case so that the player will not move above the screen
            if((playerView.center.y <= (0 + edgeConstant)) && (delta.y > 0))
            {
                //at the top of the screen, we move left/right but not upwards as vertical acceleration dictates
                playerView.center = CGPointMake(playerView.center.x, (playerView.center.y));   
            }
            //if not on the ground/ at the top of the screen
            else
            {
                //we move left/right by accelerometer data and up/down with vertical acceleration
                playerView.center = CGPointMake(playerView.center.x, (playerView.center.y - delta.y));
            }
        }
    }
    
    //if the player is not in danger of leaving the screen, they will move normally based on the accelerometer's acceleration
    else
    {
        //alter speeds to get a more fluid/playable motion for positive (right) values
        if(delta.x <= 2 && delta.x > 1)
        {
            delta.x += 1;
        }
        else if(delta.x <= 3 && delta.x > 2)
        {
            delta.x += 0.5;
        }
        else if(delta.x >7)
        {
            delta.x = 7;
        }
        
        //alter speeds to get a more fluid/playable motion for negative (left) values
        if(delta.x >= -2 && delta.x < -1)
        {
            delta.x -= 1;
        }
        else if(delta.x >= -3 && delta.x < -2)
        {
            delta.x -= 0.5;
        }
        else if(delta.x < -7)
        {
            delta.x = -7;
        }
        
        //create smoother cutoff points for motion in both directions
        if((delta.x >= -1 && delta.x < -0.33) || (delta.x <= 1 && delta.x > 0.33))
        {
            delta.x = delta.x * .25;
        }
        else if(delta.x >= -0.33 && delta.x <= 0.33)
        {
            delta.x = 0;
        }
        
        //if on the ground, or if the game hasn't started
        if(playerView.center.y >= basePlayerY || [platformArray count] < 4)
        {
            //if on the ground, we must stop gravity if it is still running
            if(gravityTimer != nil)
            {
                [self stopGravity];
            }
            //on the ground, we move left/right but there is no vertical acceleration acting upon the player
            playerView.center = CGPointMake(playerView.center.x, playerView.center.y);
        }
        //if in the air
        else
        {
            //if not on the ground and the game has started, we must start gravity if it is not already running
            if(gravityCounter == 0)
            {
                [self startGravity];
            }
            
            //corner case so that the player will not move above the screen
            if((playerView.center.y <= (0 + edgeConstant)) && (delta.y > 0))
            {
                //at the top of the screen, we move left/right but not upwards as vertical acceleration dictates
                playerView.center = CGPointMake(playerView.center.x + delta.x, (playerView.center.y));   
            }
            //if not on the ground/ at the top of the screen
            else
            {
                //we move left/right by accelerometer data and up/down with vertical acceleration
                playerView.center = CGPointMake(playerView.center.x + delta.x, (playerView.center.y - delta.y));
            }
        }
    
        
        //rotates the water below (for mostly eye-candy) if the screen-rotation is over a certain threshold
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
            [UIView setAnimationDuration: accelerometerFrequency];
            waterView.transform = CGAffineTransformMakeRotation(rotation);
            [UIView commitAnimations];
            
            
            //iterates through each platform in the platform array
            CGRect playerRectangle = CGRectMake(playerView.center.x - playerWidth/2, playerView.center.y - playerHeight/2, playerWidth, playerHeight);
            
            for(UIPlatformView *platform in platformArray)
            {

                //sets the platform rectangle as the frame of a platform
                CGRect platformRectangle = platform.frame;
                
                //the player will jump if the playform and the player intersect
                if ((CGRectIntersectsRect (playerRectangle, platformRectangle)) == true)
                {
                    // we do not animate the jump if the platform is not wholly visible 
                    if(platformRectangle.origin.y >= (platformHeight))
                    {
                        [self stopGravity];
                        [self jump];
                    }
                }
                      

            }
            
            //Compare if the water and player are touching.  If so, the player must have fallen and should then lose the game
            CGRect waterRectangle = CGRectMake(0, 440, 320, 45);
            
            if ((CGRectIntersectsRect (playerRectangle, waterRectangle)) == true)
            {
                [self gameOver];
                
                
            }

        }
        
    }
   
}



    


-(void) onTimer
{
    //creates an instance of a platform
    platformView = [[UIPlatformView alloc] initWithImage:platformImage];
	
    

    
    
	// every time the timer is called the platform is created at a random location of 3, which is a random integer % 3 rounded, so it could only be 0,1, or 2.  It is then multiplied by 106 so that it spawns at the correct third of the screen (left, center, or right)
	int spawnX =(round(random() % 3));

    spawnX = spawnX * 106 + 1;
    
    //the first platform spawns in the middle so we can begin jumping
    if(currentScore == 0)
    {
        spawnX = 107;
    }
    
    // set the platform start position
	platformView.frame = CGRectMake(spawnX, -100, platformWidth, platformHeight);
	platformView.alpha = 0.80;
        
	
	// put the platform in the main view and bring the score label to the front
	[self.view insertSubview:platformView belowSubview: scoreLabel];
    
    //one gains 10 * (the number of platforms that have gone by) for every platform that the player survives
    platformCounter++;
   currentScore = currentScore + (10 * platformCounter);
    
    //corner case to prevent (a highly improbable score) from overflowing the scoreLabel graphically
    if (currentScore > 99999999)
    {
        currentScore = 99999999;
    }
    
    //sets the score label to present the updated score
    scoreLabel.text = [NSString stringWithFormat: @"  Score: %d", currentScore];
	
    /*** 
     NOTE: this is where we had serious issues (because we were trying to use an uneditable animation as our platforms).  After this revelation we simplified our array, even though it is not as complex or useful, it is sufficient for v 1.0 
     ***/
    
    //iterates through the platform array and inserts the new platform into the first available spot   

        [platformArray insertObject:platformView atIndex:arrayCounter];
        arrayCounter++;
    
    
    //sets the index ivar for the UIPlatformView to i, so that one can find it in the array later for easy removal
    platformView.platformIndex = platformCounter;
    platformView.arrayIndex = arrayCounter; 
	

}
-(void) gameOver{
    
    // we set the game won bool to won so that our modifcations to our alert will function and so that we can signal elsewhere as well to stop normal game functionality
    gameWon = YES;
    
    [self stopAccelerometer];
    
    // we set the player to stay in the water at their current x position
    playerView.center=CGPointMake(playerView.center.x,425);

    //stops all timers
    [platformTimer invalidate];
    platformTimer = nil;
    
    
    [gravityTimer invalidate];
    gravityTimer = nil;
    
    [movementTimer invalidate];
    movementTimer = nil;
    
    //removes all platforms from the screen 
    [platformArray removeAllObjects];
    
    //submits score to gamecenter
    [self submitScore];

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Game Over"
                          message:[NSString stringWithFormat:@"Your Score: %d Points!", currentScore]
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Main Menu", nil];
    [alert show];
    [alert release];
    
    
}



- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end

