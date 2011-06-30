//
//  MusicPlayerCore.m
//  MusicPlayerTester
//
//  Created by User on 06.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "MusicPlayerCore.h"

static int currentTime;
static int slower;
static int kSlower; // number of subbuffers
static int numPacketsInSubbuffer;  

@implementation MusicPlayerCore

@synthesize action;

static void MyAQOutputCallback(void* inUserData, AudioQueueRef inAQ, 
                               AudioQueueBufferRef inCompleteAQBuffer)
{ 
	currentTime++;
    
    //	Header for Audio Queue Callback and Casting of User Info Pointer
	MyPlayer *aqp = (MyPlayer*)inUserData; 
	if (aqp->isDone) return;
    
    //  Reading Packets from Audio File
    
	UInt32 nPackets = aqp->numPacketsToRead;
    
    numPacketsInSubbuffer = (int) (nPackets / kSlower);
	void* audioData = malloc(slower*nPackets*sizeof(short int));
	void* copyData = malloc(slower*nPackets*sizeof(short int));
    
    AudioFileReadBytes(aqp->playbackFile, false, aqp->packetPosition, &nPackets, 
                                  audioData);
    
	memcpy(copyData,audioData,nPackets);
	
    //  duplicating with variable length numPacketsInSubbuffer
    for(int i=0; i<kSlower; i++) {
        for(int j=0; j<numPacketsInSubbuffer; j++) {
            ((short int*) audioData)[slower*i*numPacketsInSubbuffer+j] = ((short int*) copyData)[i*numPacketsInSubbuffer+j];            
            ((short int*) audioData)[slower*i*numPacketsInSubbuffer+numPacketsInSubbuffer+j] = ((short int*) copyData)[i*numPacketsInSubbuffer+j];            
        }
    }
    
	memcpy(inCompleteAQBuffer->mAudioData, audioData, slower*nPackets);	
	
    //  Enqueuing Packets for Playback
	if (nPackets > 0) {
		inCompleteAQBuffer->mAudioDataByteSize = slower*nPackets; 
		AudioQueueEnqueueBuffer(inAQ,inCompleteAQBuffer, (aqp->packetDescs ? nPackets : 0),aqp->packetDescs);
		aqp->packetPosition += nPackets;						
	}
    //  Stopping Audio Queue Upon Reaching End of File
	else {
        AudioQueueStop(inAQ, false);
	}
}


- (id) initWithFile:(NSString*)fileName withType:(NSString*)fileType
{
    slower = 2;
    kSlower = 10;
    
//    NSURL* fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:fileType]];

    notes = [self getDataFromFile:@"data" withType:@"txt"];
    
	timer = [NSTimer
			 scheduledTimerWithTimeInterval: 0.01
			 target:self
			 selector:@selector(timeTick)
			 userInfo:nil
			 repeats:YES];
	
	[timer retain];    
    action = STOP;
    
    [self start];
    
    return self;
}

- (void) start
{
    //	Open an audio file
    
	CFURLRef myFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, kPlaybackFileLocation, 													   kCFURLPOSIXPathStyle, false);
    
    AudioFileOpenURL(myFileURL, 0x01, 0, &player.playbackFile);
    
	CFRelease(myFileURL);		
	
    //	Set up format 
	AudioStreamBasicDescription dataFormat; 
	UInt32 propSize = sizeof(dataFormat); 
    
    AudioFileGetProperty(player.playbackFile, kAudioFilePropertyDataFormat,&propSize, &dataFormat);
    
	dataFormat.mSampleRate = dataFormat.mSampleRate * 1.0; // changing pitch by samplerate
	
    //	Set up queue 
    //  Creating a new Audio Queue for Output
    //	AudioQueueRef queue;
    
    AudioQueueNewOutput(&dataFormat, &MyAQOutputCallback, &player, NULL, NULL,0,&queue);
    
    //  Calling a Convenience Function to Calculate Playback Buffer Size and Number of Packets to Read
    
    [self CalculateBytesForTime: player.playbackFile : dataFormat : 0.2 : &bufferByteSize : &player.numPacketsToRead];
    
    
    //  Allocating Memory for Packet Descriptions Array
	bool isFormatVBR = (dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0);
	if (isFormatVBR) {
		player.packetDescs = (AudioStreamPacketDescription*)		
		malloc(sizeof(AudioStreamPacketDescription) * player.numPacketsToRead);
	}
	else 
		player.packetDescs = NULL;
    
    //  Calling a Convenience Method to Handle Magic Cookie	
    
    [self MyCopyEncoderCookieToQueue:player.playbackFile : queue];
    
    //  Allocating and Enqueuing Playback Buffers
    
	player.isDone = false; 
	player.packetPosition = 0; 
    

}

- (void) play
{    
    action = PLAY;
	for (int i = 0; i < kNumberPlaybackBuffers; ++i) {
        AudioQueueAllocateBuffer(queue, bufferByteSize, &buffers[i]);
        MyAQOutputCallback(&player, queue, buffers[i]);
		if (player.isDone) 
			break;
	}
	
    //	Start queue 
    //  Starting the Playback Audio Queue
	
    AudioQueueStart(queue, NULL);
    
	NSLog(@"Playing...\n"); 
	do {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.25, false); 
	}
    while (!player.isDone);
	
    //  Delaying to Ensure Queue Plays Out Buffered Audio
	CFRunLoopRunInMode(kCFRunLoopDefaultMode, 2, false);
	
    //	Clean up queue when finished 
	player.isDone = true; 
    
    AudioQueueStop(queue, TRUE);
    
	AudioQueueDispose(queue, TRUE); 
	AudioFileClose(player.playbackFile);    
}

- (void) pause 
{
    action = PAUSE;
    AudioQueuePause(queue);
}

- (void) stop
{
//    slower = 1;
    action = STOP;
    AudioQueueStop(queue, TRUE);
}

- (void) setVolume:(float)_volume
{
    AudioQueueSetParameter(queue, kAudioQueueParam_Volume, _volume);
}

- (void) setSpeed:(float)_speed
{
}


- (CGPoint) getCurrentNote
{
    int nota = (currentTime % 100);
    NSValue* point = (NSValue*) [notes objectForKey:[NSString stringWithFormat:@"%d",nota]];

    return [point CGPointValue];
}
 
- (NSMutableDictionary*) getDataFromFile:(NSString*) fileName withType:(NSString*) fileType
{
    
    NSMutableDictionary* _notes = [[NSMutableDictionary alloc] init];
 
    NSString* fileRoot = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
 
    NSString* fileContents = [NSString stringWithContentsOfFile:fileRoot 
                                        encoding:NSUTF8StringEncoding error:nil];
 
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:
                                [NSCharacterSet newlineCharacterSet]];
 
    for (int i=0; i<[allLinedStrings count]; i++) {
        NSString* currentPointString = [allLinedStrings objectAtIndex:i];
        NSArray* singleStrs = [currentPointString componentsSeparatedByCharactersInSet:
                               [NSCharacterSet characterSetWithCharactersInString:@","]];
 
        int x = [[singleStrs objectAtIndex:0] intValue];
        int y = [[singleStrs objectAtIndex:1] intValue];
        int nota = [[singleStrs objectAtIndex:2] intValue];
 
        [_notes setObject:[NSValue valueWithCGPoint:CGPointMake(x,y)] 
                   forKey:[NSString stringWithFormat:@"%d",nota]];	
 
    }	
 
    return _notes;
}

- (void) timeTick
{
    if (action==PLAY) {
        currentTime++;
//        NSLog(@"Timer = %d",currentTime);
    }
    
}

-(void) CheckError: (OSStatus) error :(NSString*)operation
{
	if (error == noErr) return;
	
	char errorString[20]; // See if it appears to be a 4-char-code 
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error); 
	
	if ( isprint(errorString[1]) && isprint(errorString[2]) 
		&& isprint(errorString[3]) && isprint(errorString[4]) ) { 
		
        errorString[0] = errorString[5] = '\''; 
        errorString[6] = '\0';
	} 
	else // No, format it as an integer 
        NSLog(@"%@, %d",errorString,(int)error);
    
    NSLog(@"Error: %@ (%@)\n",operation,errorString);
    exit(1);
}

// Copying Magic Cookie from Audio File to Audio Queue
-(void) MyCopyEncoderCookieToQueue: (AudioFileID)theFile : (AudioQueueRef)_queue 
{
	UInt32 propertySize; 
	OSStatus result = AudioFileGetPropertyInfo (theFile,kAudioFilePropertyMagicCookieData, &propertySize, NULL); 
	
	if (result == noErr && propertySize > 0) {
		Byte* magicCookie = (UInt8*)malloc(sizeof(UInt8) * propertySize); 
        [self CheckError:AudioFileGetProperty (theFile,kAudioFilePropertyMagicCookieData, &propertySize,magicCookie) : @"Get cookie from file failed"];

        [self CheckError:(AudioQueueSetProperty(_queue,kAudioQueueProperty_MagicCookie, magicCookie,propertySize)) :@"Set cookie on queue failed"];
                          
		free(magicCookie);
	}
}

// Calculating Buffer Size and Maximum Number of Packets That Can Be Read Into the Buffer
-(void) CalculateBytesForTime: (AudioFileID) inAudioFile : (AudioStreamBasicDescription) inDesc 
                             : (Float64) inSeconds : (UInt32*) outBufferSize : (UInt32*) outNumPackets 
{
	UInt32 maxPacketSize;
	UInt32 propSize = sizeof(maxPacketSize);
    
    [self CheckError: AudioFileGetProperty(inAudioFile,kAudioFilePropertyPacketSizeUpperBound, &propSize, &maxPacketSize) : @"Couldn't get file's max packet size" ];
    
	static const int maxBufferSize = 0x10000;
	static const int minBufferSize = 0x4000;
	
	if (inDesc.mFramesPerPacket) {
		Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
		*outBufferSize = numPacketsForTime * maxPacketSize;
	}
	else {
		*outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
	}
	
	if (*outBufferSize > maxBufferSize && *outBufferSize > maxPacketSize)
		*outBufferSize = maxBufferSize;
	else {
		if (*outBufferSize < minBufferSize)
			*outBufferSize = minBufferSize;
	}
	
	*outNumPackets = *outBufferSize / maxPacketSize;		
}


@end
