//
//  UIPlatformView.h
//  Game
//
//  Created by Buffalo Hird on 12/8/11.
//  Copyright (c) 2011 Harvard University. All rights reserved.
//


//in our semi-dysfunctional array set up, this class is less useful.  However, in a future version, these two values would be imperative to determining whether a platform should be allowed to despawn and where it is located in the platform array so it can be removed there as well
#import <UIKit/UIKit.h>

@interface UIPlatformView : UIImageView

@property int platformIndex;
@property int arrayIndex;

@end
