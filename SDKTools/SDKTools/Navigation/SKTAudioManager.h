//
//  SKTAudioManager.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>

/** Plays sound files from a given folder in a queued manner.
 */
@interface SKTAudioManager : NSObject

/** Absolute path of the folder from where the files will be loaded.
 */
@property (atomic, strong) NSString *audioFilesFolderPath;

/** Desired playback volume.
 */
@property (nonatomic, assign) float volume;

/** Allows/forbids audio playback during calls. This is initialized by SKTNavigationManager when starting navigation or free drive.
 */
@property (atomic, assign) BOOL playAudioDuringCalls;

/** Queues audio files to be played from audioFilesFolderPath folder. Will resume playback if currently paused.
 @param audioFiles Names of the files that are to be played.
 */
- (void)play:(NSArray *)audioFiles;

/** Stops audio playback.
 */
- (void)cancel;

/** Pauses audio playback.
 */
- (void)pause;

/** Resumes audio playback.
 */
- (void)resume;

@end
