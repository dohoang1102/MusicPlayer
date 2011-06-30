//
//  MusicPlayerTesterViewController.m
//  MusicPlayerTester
//
//  Created by User on 06.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "MusicPlayerTesterViewController.h"

#define STOP    1
#define PLAY    2
#define PAUSE   3

@implementation MusicPlayerTesterViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    action = STOP;
    [super viewDidLoad];
    musicPlayerView = [[MusicPlayerView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [musicPlayerView.playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [musicPlayerView.pauseButton addTarget:self action:@selector(pauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];      
    [musicPlayerView.stopButton addTarget:self action:@selector(stopButtonPressed) forControlEvents:UIControlEventTouchUpInside];      
    
    [self.view addSubview:musicPlayerView];
    player = [[MusicPlayerCore alloc] initWithFile:@"data" withType:@"text"];
    
    
}

- (void) playButtonPressed
{
    if ([player action]==STOP) {
        [player start];
        [player play];
        NSLog(@"STOP");
        [[musicPlayerView playButton] setTitle:@"Pause" forState: UIControlStateNormal];
    }
    if ([player action]==PAUSE) {
        [player play];
        [[musicPlayerView playButton] setTitle:@"Play" forState: UIControlStateNormal];  
        NSLog(@"PAUSE");
    }
    if ([player action]==PLAY) {
        [player pause];
        [[musicPlayerView playButton] setTitle:@"Resume" forState: UIControlStateNormal];    
        NSLog(@"PLAY");
    }
}

- (void) pauseButtonPressed
{
    action = PAUSE;
    [player pause];
}

- (void) stopButtonPressed
{
    [player stop];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
