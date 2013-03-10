//
//  GameAppDelegate.h
//  Game
//
//  NOTE: this was made on Buffalo Hird's computer, hence the auto-populated headers

//  Created by Buffalo Hird on 12/1/11.
//  Copyright (c) 2011 Harvard University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface GameAppDelegate : NSObject <UIApplicationDelegate>{

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

@end
