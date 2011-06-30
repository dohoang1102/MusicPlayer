//
//  MusicPlayerCore.h
//  MusicPlayerTester
//
//  Created by User on 06.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>

#define STOP    1
#define PLAY    2
#define PAUSE   3
#define kPlaybackFileLocation	CFSTR("/Users/user/Projects/AudioQueuePlayback 2.2 (slow down - potap)/provans-mono-22050.wav")
#define kNumberPlaybackBuffers	3
#pragma mark user data struct 

typedef struct MyPlayer {
	AudioFileID playbackFile;
	SInt64 packetPosition;
	UInt32 numPacketsToRead;
	AudioStreamPacketDescription *packetDescs;
	Boolean isDone;
} MyPlayer;


@interface MusicPlayerCore : NSObject {

    NSTimer* timer;
    NSMutableDictionary* notes;
   	AudioQueueRef queue;
    MyPlayer player; 
    UInt32 bufferByteSize; 
    AudioQueueBufferRef buffers[kNumberPlaybackBuffers]; 
    int action;
}

- (id) initWithFile:(NSString*)fileName withType:(NSString*)fileType;
- (void) play;
- (void) start;
- (void) pause;
- (void) stop;
- (void) setVolume:(float)_volume;
- (void) setSpeed:(float)_speed;

- (CGPoint) getCurrentNote;
- (NSMutableDictionary*) getDataFromFile:(NSString*) fileName withType:(NSString*) fileType;
//-(void) MyAQOutputCallback: (void*) inUserData : (AudioQueueRef) inAQ: (AudioQueueBufferRef) inCompleteAQBuffer;
-(void) CalculateBytesForTime: (AudioFileID) inAudioFile : (AudioStreamBasicDescription) inDesc 
                             : (Float64) inSeconds : (UInt32*) outBufferSize : (UInt32*) outNumPackets;
-(void) MyCopyEncoderCookieToQueue: (AudioFileID)theFile : (AudioQueueRef)queue;

@property int action;

@end

