//
//  SKTAudioManager.m
//  FrameworkIOSDemo
//

//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>

#import "SKTAudioManager.h"

typedef void (^CallHandler)(CTCall *call);

@interface SKTAudioManager () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSMutableArray *audioFilesArray;
@property (nonatomic, strong) CTCallCenter *callCenter;
@property (atomic, assign, getter = isPhoneCallActive) BOOL phoneCallActive;
@property (nonatomic, assign) BOOL paused;

#if !OS_OBJECT_USE_OBJC
@property (nonatomic, assign) dispatch_queue_t queue;
#else
@property (nonatomic, strong) dispatch_queue_t queue;
#endif

@end

@implementation SKTAudioManager

#pragma mark - Lifecycle

- (id)init {
	self = [super init];
	if (self) {
		self.audioPlayer = nil;
		self.audioFilesArray = [NSMutableArray array];
        self.queue = dispatch_queue_create("audio_queue", DISPATCH_QUEUE_SERIAL);
        self.audioFilesFolderPath = @"";
        self.callCenter = [[CTCallCenter alloc] init];
        self.callCenter.callEventHandler = [self callHandlerBlock];
        self.paused = NO;
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew context:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	}
	return self;
}

- (void)dealloc {
	self.audioPlayer.delegate = nil;
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"];
    [self.audioPlayer stop];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_queue);
#endif
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"outputVolume"]) {
        dispatch_async(_queue, ^{
            [self updateVolume];
        });
    }
}

#pragma mark - Public methods

- (void)play:(NSArray *)audioFiles {
    dispatch_async(_queue, ^{
        if (!self.playAudioDuringCalls && self.isPhoneCallActive) {
            return;
        }
		[self.audioFilesArray addObjectsFromArray:audioFiles];
		if ((self.audioFilesArray.count > 0) && !self.audioPlayer.isPlaying && !self.paused) {
            [self playNext];
		}
	});
}

- (void)playAudioFile:(NSString *)audioFileName {
    self.paused = NO;
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    if (self.audioPlayer) {
        self.audioPlayer.delegate = nil;
        self.audioPlayer = nil;
    }
    
    NSString *soundFilePath = [self.audioFilesFolderPath stringByAppendingPathComponent:audioFileName];
    soundFilePath = [soundFilePath stringByAppendingPathExtension:@"mp3"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:soundFilePath]) {
        return;
    } else {
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundFilePath] error:&error];
        self.audioPlayer.delegate = self;
        [self updateVolume];
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
    }
}

- (void)playNext {
    if (self.audioFilesArray.count > 0) {
        [self playAudioFile:self.audioFilesArray[0]];
        [self.audioFilesArray removeObjectAtIndex:0];
    }
}

- (void)cancel {
    dispatch_async(_queue, ^{
    	[self.audioPlayer stop];
        self.audioPlayer.delegate = nil;
        self.audioPlayer = nil;
        [self.audioFilesArray removeAllObjects];
    });
}

- (void)pause {
    dispatch_async(_queue, ^{
        self.paused = YES;
        [self.audioPlayer pause];
    });
}

- (void)resume {
    dispatch_async(_queue, ^{
        if (self.audioPlayer && ![self.audioPlayer isPlaying]) {
            NSError *error = nil;
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            self.paused = NO;
            [self.audioPlayer play];
        } else {
            [self playNext];
        }
    });
}

- (void)setVolume:(float)volume {
    dispatch_async(_queue, ^{
        _volume = volume;
        [self updateVolume];
    });
}

- (void)updateVolume {
    self.audioPlayer.volume = [[AVAudioSession sharedInstance] outputVolume];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    dispatch_async(_queue, ^{
        if (self.audioFilesArray.count > 0) {
            [self playNext];
        } else {
            self.audioPlayer.delegate = nil;
            self.audioPlayer = nil;
        }
    });
}

- (CallHandler)callHandlerBlock {
    __weak  SKTAudioManager *weakSelf = self;
    return ^(CTCall *call) {
        __strong SKTAudioManager *strongSelf = weakSelf;
        if ([call.callState isEqualToString:CTCallStateIncoming] || [call.callState isEqualToString:CTCallStateConnected]) {
            strongSelf.phoneCallActive = YES;
            if (!strongSelf.playAudioDuringCalls) {
                [strongSelf cancel];
                [strongSelf pause];
            }
        }
        
        if ([call.callState isEqualToString:CTCallStateDisconnected]) {
            strongSelf.phoneCallActive = NO;
            [strongSelf resume];
        }
    };
}

@end
