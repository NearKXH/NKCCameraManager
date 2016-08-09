//
//  NDefaultViewController.m
//  NCamera
//
//  Created by NearKong on 16/6/25.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NDefaultViewController.h"

#import "NAudioManager.h"
#import "NCameraManager.h"

@interface NDefaultViewController ()
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet UIView *topBarView;

@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (weak, nonatomic) IBOutlet UIButton *movieRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *audioRecordButton;

@property (weak, nonatomic) IBOutlet UIView *movieView;
@property (weak, nonatomic) IBOutlet UIView *movieFlashView;
@property (weak, nonatomic) IBOutlet UILabel *movieLabel;

@property (weak, nonatomic) IBOutlet UIView *audioView;
@property (weak, nonatomic) IBOutlet UIView *audioFlashView;
@property (weak, nonatomic) IBOutlet UILabel *audioLabel;

@property (nonatomic, strong) NCameraManager *manager;
@property (nonatomic, strong) NAudioManager *audioManager;

@property (nonatomic, assign) NCameraManagerFlashMode flashMode;

@property (nonatomic, strong) NSTimer *audioTimer;
@property (nonatomic, strong) NSTimer *movieTimer;
@property (nonatomic, assign) NSInteger audioCount;
@property (nonatomic, assign) NSInteger movieCount;
@end

@implementation NDefaultViewController

- (void)dealloc {
    [self removeAllTimer];
    NSLog(@"--dealloc--NDefaultViewController");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:true];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self configUI];
    [self configData];
}

- (void)configUI {
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    //    self.topBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];

    self.audioFlashView.layer.masksToBounds = true;
    self.audioFlashView.layer.cornerRadius = 8.0f;
    self.audioView.layer.masksToBounds = true;
    self.audioView.layer.cornerRadius = 4.0f;
    self.audioView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];

    self.movieFlashView.layer.masksToBounds = true;
    self.movieFlashView.layer.cornerRadius = 8.0f;
    self.movieView.layer.masksToBounds = true;
    self.movieView.layer.cornerRadius = 4.0f;
    self.movieView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
}

- (void)configData {
}

#pragma mark - Action
- (IBAction)changeCameraAction:(id)sender {
    //    [self.manager changeCameraWithHandle:^(NCameraSetupResult setupResult, NSError *error) {
    //        if (setupResult != NCameraSetupResultSuccess || error) {
    //            NSLog(@"\n--result = %ld\nerror = %@--", setupResult, error);
    //        } else {
    //            NSLog(@"--Scuess--");
    //        }
    //    }];
}

- (IBAction)changeFlashAction:(id)sender {
    NSLog(@"--changeFlashAction--");
}

- (IBAction)stillImageAction:(id)sender {
    NSLog(@"--stillImageAction--");
}

- (IBAction)movieRecordAction:(id)sender {
    //    if (self.manager.isMovieRecording) {
    //        [self updateShowModeWhenMovieRecordStart:false];
    //        [self.manager stopMovieRecord];
    //
    //    } else {
    //        [self updateShowModeWhenMovieRecordStart:true];
    //        [self.manager startMovieRecord];
    //    }
}

- (IBAction)audioRecordAction:(id)sender {
    //    if (self.audioManager.isAudioRecording) {
    //        [self updateShowModeWhenAudioRecordStart:false];
    //        [self.audioManager stopAudioRecord];
    //    } else {
    //        [self updateShowModeWhenAudioRecordStart:true];
    //        [self.audioManager startAudioRecord];
    //    }
}

- (IBAction)jumpToPhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:true completion:nil];
}


#pragma mark - change Show Mode When Movie Record Or Audio Record
static NSTimeInterval const kMovieChangeViewTime = 0.5f;
- (void)updateShowModeWhenMovieRecordStart:(BOOL)isStartRecord {
    if (isStartRecord) {
        self.movieView.hidden = false;
        self.movieCount = 0;
        self.movieTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateMovieLabelCount) userInfo:nil repeats:true];
        [self.movieRecordButton setImage:[UIImage imageNamed:@"film-on"] forState:UIControlStateNormal];
        [UIView animateWithDuration:kMovieChangeViewTime
                         animations:^{
                             self.topBarView.alpha = 0;
                             self.bottomBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
                         }];
    } else {
        self.movieView.hidden = true;
        self.movieCount = 0;
        [self removeMovieTimer];
        [self.movieRecordButton setImage:[UIImage imageNamed:@"film"] forState:UIControlStateNormal];
        [UIView animateWithDuration:kMovieChangeViewTime
                         animations:^{
                             self.topBarView.alpha = 1;
                             self.bottomBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0f];
                         }];
    }
}

- (void)updateShowModeWhenAudioRecordStart:(BOOL)isStartRecord {
    if (isStartRecord) {
        [self.audioRecordButton setImage:[UIImage imageNamed:@"audio-on"] forState:UIControlStateNormal];
        self.audioView.hidden = false;
        self.audioCount = 0;
        self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateAudioLabelCount) userInfo:nil repeats:true];
    } else {
        [self.audioRecordButton setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
        self.audioView.hidden = true;
        self.audioCount = 0;
        [self removeAudioTimer];
    }
}

- (void)updateMovieLabelCount {
    self.movieCount++;
    NSInteger second = self.movieCount % 60;
    NSInteger minute = self.movieCount / 60 % 60;
    NSInteger hours = self.movieCount / 3600;

    NSString *secondString = [[NSString stringWithFormat:@"0%ld", second] substringWithRange:NSMakeRange([@(second) description].length - 1, 2)];
    NSString *minuteString = [[NSString stringWithFormat:@"0%ld", minute] substringWithRange:NSMakeRange([@(minute) description].length - 1, 2)];
    NSString *hoursString =
        [[NSString stringWithFormat:@"0%ld", hours] substringWithRange:NSMakeRange([@(hours) description].length - 1, [@(hours) description].length)];

    self.movieLabel.text = [NSString stringWithFormat:@"%@:%@:%@", hoursString, minuteString, secondString];
    self.movieFlashView.hidden = self.movieCount % 2;
}

- (void)updateAudioLabelCount {
    self.audioCount++;
    NSInteger second = self.audioCount % 60;
    NSInteger minute = self.audioCount / 60 % 60;
    NSInteger hours = self.audioCount / 3600;

    NSString *secondString = [[NSString stringWithFormat:@"0%ld", second] substringWithRange:NSMakeRange([@(second) description].length - 1, 2)];
    NSString *minuteString = [[NSString stringWithFormat:@"0%ld", minute] substringWithRange:NSMakeRange([@(minute) description].length - 1, 2)];
    NSString *hoursString =
        [[NSString stringWithFormat:@"0%ld", hours] substringWithRange:NSMakeRange([@(hours) description].length - 1, [@(hours) description].length)];

    self.audioLabel.text = [NSString stringWithFormat:@"%@:%@:%@", hoursString, minuteString, secondString];
    self.audioFlashView.hidden = self.audioCount % 2;
}

- (void)removeAllTimer {
    [self removeAudioTimer];
    [self removeMovieTimer];
}

- (void)removeAudioTimer {
    if (self.audioTimer.isValid) {
        [self.audioTimer invalidate];
    }
}

- (void)removeMovieTimer {
    if (self.movieTimer.isValid) {
        [self.movieTimer invalidate];
        self.movieTimer = nil;
    }
}

#pragma mark - System
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
