//
//  DefaultAlert.h
//  FMP_Proj
//
//  Created by betty on 14-7-7.
//  Copyright (c) 2014年 betty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>
#import "IAlert.h"

@interface DefaultAlert : IAlert<AVAudioPlayerDelegate>{
    CFURLRef soundFileURLRef;
    SystemSoundID soundFileObject;
    NSTimer *alertTimer;
    AVAudioSession *audioSession;
    AVAudioPlayer *avAudioPlayer; 
    
}

@property (readwrite) CFURLRef soundFileURLRef;
@property (readonly) SystemSoundID soundFileObject;


//-(void) playSystemSound;
-(void)playAlertSound;
-(void) stopAlert;
//-(Boolean) isPlay;

@end
