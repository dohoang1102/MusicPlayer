//
//  MusicPlayerView.h
//  MusicPlayerTester
//
//  Created by User on 06.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MusicPlayerView : UIView {
    
    UIButton* playButton;
    UIButton* pauseButton;
    UIButton* stopButton;
    
    UISlider* volumeSlider;
    UISlider* speedSlider;
    
}

@property (nonatomic, retain) UIButton* playButton;
@property (nonatomic, retain) UIButton* pauseButton;
@property (nonatomic, retain) UIButton* stopButton;

@end
