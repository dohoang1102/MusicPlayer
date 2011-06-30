//
//  MusicPlayerTesterAppDelegate.h
//  MusicPlayerTester
//
//  Created by User on 06.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MusicPlayerTesterViewController;

@interface MusicPlayerTesterAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MusicPlayerTesterViewController *viewController;

@end
