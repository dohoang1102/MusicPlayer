//
//  MusicPlayerView.m
//  MusicPlayerTester
//
//  Created by User on 06.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "MusicPlayerView.h"


@implementation MusicPlayerView

@synthesize playButton, pauseButton, stopButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
        
        playButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
        pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 150, 100, 50)];
        stopButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 50)];

        [playButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [playButton setTitle:@"Play" forState:UIControlStateNormal];
        [playButton setBackgroundColor:[UIColor grayColor]];
        [playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [pauseButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        [pauseButton setBackgroundColor:[UIColor grayColor]];
        [pauseButton addTarget:self action:@selector(pauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [stopButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
        [stopButton setBackgroundColor:[UIColor grayColor]];
        [stopButton addTarget:self action:@selector(stopButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:playButton];
        [self addSubview:pauseButton];
        [self addSubview:stopButton];

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

- (void) playButtonPressed
{
    if ([playButton alpha]==0.5) {
        [playButton setAlpha:1.0];
    }
    else {
        [playButton setAlpha:0.5];  
        [pauseButton setAlpha:1.0];
        [stopButton setAlpha:1.0];    
    }
}

- (void) pauseButtonPressed
{
    if ([pauseButton alpha]==0.5) {
        [pauseButton setAlpha:1.0];
    }
    else {
        [pauseButton setAlpha:0.5];
        [playButton setAlpha:1.0];
        [stopButton setAlpha:1.0];    
    }    
}

- (void) stopButtonPressed
{
    if ([stopButton alpha]==0.5) {
        [stopButton setAlpha:1.0];
    }
    else {
        [stopButton setAlpha:0.5];        
        [pauseButton setAlpha:1.0];
        [playButton setAlpha:1.0];
    }        
}

- (void)dealloc
{
    [super dealloc];
}

@end
