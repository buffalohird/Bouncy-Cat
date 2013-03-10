//
//  RootViewController.h
//  Game
//
//  Created by Buffalo Hird on 12/4/11.
//  Copyright (c) 2011 Harvard University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#import "GameCenterManager.h"





@class GameViewController;
@class GameCenterManager;

@interface RootViewController : UIViewController <UIAccelerometerDelegate, UIActionSheetDelegate, GKLeaderboardViewControllerDelegate, GameCenterManagerDelegate>
{
    GameCenterManager *gameCenterManager;
}

@property (nonatomic, retain) IBOutlet UIButton *gameButton;
@property (nonatomic, retain) IBOutlet UIButton *gamecenterButton;
@property (nonatomic, retain) UIImage *rootBackground;
@property (nonatomic, retain) UIImageView *rootBackgroundView;
@property (nonatomic, retain) UIAccelerometer *accelerometer;
@property (nonatomic, retain) UIImage *water;
@property (nonatomic, retain) UIImageView *waterView;
@property (nonatomic, retain) GameCenterManager *gameCenterManager;
@property (nonatomic, retain) NSString* currentLeaderBoard;



- (IBAction)gameView:(id)sender;
- (IBAction)showLeaderboard:(id)sender;
- (void)startAccelerometer;
- (void)stopAccelerometer;


@end
