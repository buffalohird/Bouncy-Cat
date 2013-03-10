//
//  GameViewController.h
//  Game
//
//  Created by Buffalo Hird on 12/1/11.
//  Copyright (c) 2011 Harvard University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#import "UIPlatformView.h"

#import "GameCenterManager.h"



@class GameCEnterManager;

@interface GameViewController : UIViewController <UIAccelerometerDelegate, UIAlertViewDelegate, UIActionSheetDelegate,GameCenterManagerDelegate> {
    
    CGPoint delta;
    NSMutableArray *platformArray;
    int arrayCounter;
    int platformCounter;
    int64_t currentScore;
    int gravityCounter;
    int gravity;
    float velocityY;
    int incrementArray;
    int front;
    float deltaYPlatform;
    int level;
    GameCenterManager *gameCenterManager;
	NSString* currentLeaderBoard;
}




@property (nonatomic, retain) UIImage *playerImage;
@property (nonatomic, retain) UIImage *platformImage;
@property (nonatomic, retain) UIImage *background;
@property (nonatomic, retain) UIImage *water;
@property (nonatomic, retain) UIImageView *playerView;
@property (nonatomic, retain) UIPlatformView *platformView;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) UIImageView *waterView;
@property CGPoint delta;
@property (nonatomic, retain) IBOutlet UIButton *menuButton;
@property (nonatomic, retain) NSTimer *gravityTimer;
@property (nonatomic, retain) NSTimer *platformTimer;
@property (nonatomic, retain) NSTimer *movementTimer;
@property (nonatomic, retain) UILabel *scoreLabel;
@property (nonatomic, retain) UIAccelerometer *accelerometer;
@property BOOL gameWon;
@property (nonatomic, retain) UILabel *levelLabel;
@property (nonatomic, retain) GameCenterManager *gameCenterManager;
@property (nonatomic, retain) NSString* currentLeaderBoard;
@property (nonatomic, assign) int64_t currentScore;


- (void) onTimer;
- (void) onGravityTimer;
- (void) startGravity;
- (void) stopGravity;
- (void) jump;
- (void) startAccelerometer;
- (void) stopAccelerometer;
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *) acceleration;
- (void) menuView:(id)sender;
- (void) menuAlert:(id)sender;
- (void) onUpdatePlatforms;
- (void) gameOver;
- (void) playerReset;
- (void) levelComplete;
- (void) submitScore;



@end
