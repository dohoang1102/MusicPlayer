//
//  MusicPlayerTesterViewController.h
//  MusicPlayerTester
//
//  Created by User on 06.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicPlayerView.h"
#import "MusicPlayerCore.h"

@interface MusicPlayerTesterViewController : UIViewController {
    MusicPlayerView* musicPlayerView;
    int action;
    MusicPlayerCore* player;
}

@end
