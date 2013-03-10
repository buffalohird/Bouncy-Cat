//
//  UIPlatformView.m
//  Game
//
//  Created by Buffalo Hird on 12/8/11.
//  Copyright (c) 2011 Harvard University. All rights reserved.
//

#import "UIPlatformView.h"

@implementation UIPlatformView

@synthesize platformIndex;
@synthesize arrayIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.platformIndex = 0;
        self.arrayIndex = 0;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end


