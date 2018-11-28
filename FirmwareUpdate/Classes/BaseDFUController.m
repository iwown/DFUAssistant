//
//  BaseDFUController.m
//  ZLYIwown
//
//  Created by caike on 16/8/31.
//  Copyright © 2016年 Iwown. All rights reserved.
//
#import <MBProgressHUD.h>
#import <Lottie/Lottie.h>
#import <IVBaseKit/IVBaseKit.h>
#import <Masonry/Masonry.h>
#import "BaseDFUController.h"
#import "DFUAlertView.h"
#import "DFUOverView.h"
#import "YSProgressView.h"
#import "Toast.h"
#import "FUHandle.h"

@interface BaseDFUController ()
{
    LOTAnimationView    *_gifView;
    YSProgressView      *_udView;
    UILabel             *_udStateLab;
    UILabel             *_udProgressLab;
    UILabel             *_udTimeNoticeLab;
    UILabel             *_udTipLab;
    UILabel             *_bgTipLab;
    
    NSInteger           _timeNeed;
}
@end

@implementation BaseDFUController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)signOffDelegate {}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

    [self initParam];
    [self initUI];
}

- (void)initParam {}

#pragma mark UI
- (void)initUI {

    [self drawBackGroundView];
    [self addReturnButton];
}

- (void)addReturnButton {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 20, 80, 30)];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(returnBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

static int bgview_tag = 9239;
- (void)drawBackGroundView {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upgrade_p_bg"]];
    imgView.tag = bgview_tag;
    [imgView setFrame:self.view.bounds];
    _bgTipLab = [[UILabel alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT*0.65, SCREEN_WIDTH*(1-0.24), FONT(90))];
    [_bgTipLab setNumberOfLines:0];
    [_bgTipLab setTextAlignment:NSTextAlignmentLeft];
    [_bgTipLab setTextColor:[UIColor whiteColor]];
    [imgView addSubview:_bgTipLab];
    [[self view] addSubview:imgView];
}

- (void)drawUpdateCircle {
    
    CGFloat topGap = NavigationBarHeight + FONT(81);
    _gifView = [LOTAnimationView animationNamed:@"data_dfu"];
    _gifView.frame = CGRectMake(0.5 * (SCREEN_WIDTH - 206), topGap, 206, 206);
    [self.view addSubview:_gifView];
    [_gifView playWithCompletion:^(BOOL animationFinished) {
        // Do Something
    }];
    [_gifView setLoopAnimation:YES];
    
    _udView = [[YSProgressView alloc] initWithFrame:CGRectMake(0.5 * (SCREEN_WIDTH - 236), topGap+206, 236, 10)];
    [[self view] addSubview:_udView];
}

- (void)drawBottomBtn {
    
    if (_udBtn) {
        return;
    }
    _udBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_udBtn setFrame:CGRectMake(0.5*(SCREEN_WIDTH-FONT(230)), SCREEN_HEIGHT-FONT(120), FONT(230), FONT(50))];
    [_udBtn addTarget:self action:@selector(udBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_udBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_udBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];

    [_udBtn setBackgroundColor:[UIColor colorFromCode:0x2C79DA inAlpha:0.8]];
    [_udBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[_udBtn layer] setMasksToBounds:YES];
    [[_udBtn layer] setCornerRadius:FONT(5)];
    [[_udBtn titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [[self view] addSubview:_udBtn];
    [[self view] bringSubviewToFront:_udBtn];
}

- (void)drawStateInfoView {
    
    _udStateLab = [[UILabel alloc] initWithFrame:CGRectMake(0, NavigationBarHeight + FONT(25), SCREEN_WIDTH, FONT(40))];
    [_udStateLab setText:@"装备升级"];
    [_udStateLab setTextAlignment:NSTextAlignmentCenter];
    [_udStateLab setTextColor:[UIColor whiteColor]];
    [_udStateLab setNumberOfLines:0];
    [_udStateLab setFont:[UIFont systemFontOfSize:FONT(14)]];
    
    _udProgressLab = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*0.588 +FONT(30), SCREEN_WIDTH, FONT(30))];
    [_udProgressLab setText:NSLocalizedString(@"- 0% -", nil)];
    [_udProgressLab setTextAlignment:NSTextAlignmentCenter];
    [_udProgressLab setTextColor:[UIColor whiteColor]];
    [_udProgressLab setFont:[UIFont systemFontOfSize:FONT(20)]];
    
    _udTimeNoticeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*0.588 +FONT(65), SCREEN_WIDTH, FONT(25))];
    [_udTimeNoticeLab setText:@"剩余0分钟"];
    [_udTimeNoticeLab setTextAlignment:NSTextAlignmentCenter];
    [_udTimeNoticeLab setTextColor:[UIColor whiteColor]];
    [_udTimeNoticeLab setFont:[UIFont systemFontOfSize:FONT(14)]];

    [[self view] addSubview:_udStateLab];
    [[self view] addSubview:_udProgressLab];
    [[self view] addSubview:_udTimeNoticeLab];
}

- (void)drawTipsView {
    
    if (_udTipLab) {
        return;
    }
    NSString *title = @"请保持设备电量充足";
    _udTipLab = [UILabel labelWithFrame:CGRectMake(FONT(20), SCREEN_HEIGHT*0.73, SCREEN_WIDTH-FONT(40), FONT(150)) withTitle:title titleFontSize:[UIFont systemFontOfSize:20] textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    [_udTipLab setNumberOfLines:0];
    [_udTipLab setAdjustsFontSizeToFitWidth:YES];

    [[self view] addSubview:_udTipLab];
}

- (void)layoutUpgradeView {
    
    [_udProgressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_udView.mas_bottom).offset(FONT(10));
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, FONT(30)));
        make.left.equalTo(self.view);
    }];
    
    [_udTimeNoticeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_udProgressLab.mas_bottom).offset(FONT(10));
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, FONT(20)));
        make.left.equalTo(self.view);
    }];
    
    [_udTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_udTimeNoticeLab.mas_bottom).offset(FONT(10));
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-FONT(20), FONT(100)));
        make.left.equalTo(self.view).offset(FONT(20));
    }];
}

- (void)tapAction:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)prepareUpgradeView {
    
    [self drawBottomBtn];
    [self setUdbtnTitle:@"开始"];
}

- (void)prepareNoUpdateView {
    
    [_bgTipLab setText:@"最新版本，无需升级"];
    self.state = DFUState_Return;
    [self drawBottomBtn];
    [self setUdbtnTitle:@"点击返回"];
}

- (void)entryUpgradeView {
    
    UIImageView *bgView = [self.view viewWithTag:bgview_tag];
    bgView.image = [UIImage imageNamed:@"upgrade bg"];
    [UIView animateWithDuration:0.3 animations:^{
        self->_bgTipLab.alpha = 0;
    } completion:^(BOOL finished) {
        [self drawUpdateCircle];
        [self drawStateInfoView];
        [self drawTipsView];
        [self setUdbtnTitle:nil];
        [self layoutUpgradeView];
        [self->_gifView play];
    }];
}

- (void)prepareDFUUpgrade {
    [self entryUpgradeView];  //刷新界面
}

#pragma mark 更新UI状态
- (void)finishUpgradeUI {
    
    [_gifView stop];
    [self prepareUpgradeView];
}

- (void)removeCompleteView {
    [[self.view viewWithTag:white_tag] removeFromSuperview];
}

static int white_tag = 10299;
- (void)newCompleteAnimationView {
    
    __weak typeof(self) __safe_self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        DFUOverView * overView = [[DFUOverView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT) andSELLeft:^{
            [__safe_self completeBtnClickLeft];
        } andSELRight:^{
            [__safe_self completeBtnClickRight];
        }];
        overView.tag = white_tag;
        [self.view addSubview:overView];
        [UIView animateWithDuration:0.6 animations:^{
            [overView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        } completion:^(BOOL finished) {
            [self finishUpgradeUI];
        }];
    });
}
- (void)completeBtnClickLeft {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)completeBtnClickRight {
    
    [self removeCompleteView];
    [self setUdbtnTitle:nil];
    [_udView updateProgress:0 color:[UIColor colorFromCode:0xFFFFFF inAlpha:1]];
    [_udProgressLab setText:NSLocalizedString(@"- 0% -", nil)];
    [_udTimeNoticeLab setText:@"剩余0分钟"];
    self.state = DFUState_Retry;
    [self udBtnClicked:nil];
    [_gifView play];
}

- (void)setUdbtnTitle:(NSString *)title {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (title == nil) {
            if (self->_udTipLab == nil) {
                [self drawTipsView];
            }
            [self->_udBtn setHidden:YES];
            [self->_udTipLab setHidden:NO];
            [self->_udBtn setTitle:@"" forState:UIControlStateNormal];
        }else{
            if (self->_udBtn == nil) {
                [self drawBottomBtn];
            }
            [self->_udBtn setHidden:NO];
            [self->_udTipLab setHidden:YES];
            [self->_udBtn setTitle:title forState:UIControlStateNormal];
        }
    });
}

- (id)getStateParams:(NSString *)text
         andDFUState:(DFUState)state {
    return @{@"text":text,@"state":@(state)};
}

- (void)updateUIState:(id)stateInfo {
    
    NSString *text = (NSString *)stateInfo[@"text"];
    DFUState state = (DFUState)[stateInfo[@"state"] integerValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_udStateLab setText:text];
    });
    
    self.state = state;
    switch (state) {
        case DFUState_Null:
        {
            self.state = DFUState_Retry;
            [self setUdbtnTitle:@"重试"];
        }
            break;
        case DFUState_Return:
            [self setUdbtnTitle:@"返回"];
            break;
        case DFUState_Retry:
            [self setUdbtnTitle:@"重试"];
            break;
        case DFUState_DownLoadFial:
            [self setUdbtnTitle:@"下载"];
            break;
        case DFUState_Waiting:
            [self setUdbtnTitle:nil];
            break;
        case DFUState_Helper:
            [self setUdbtnTitle:@"升级助手"];
            break;
        case DFUState_SaveInfo:
            [self setUdbtnTitle:@"保存"];
            break;
        case DFUState_Start:
            [self setUdbtnTitle:@"开始"];
            break;
            
        default:
            break;
    }
}

- (void)finallySuccessful {
    
    [self newCompleteAnimationView];
    [self updateUIAferComplete];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *firmwareURL = [documentsDirectory stringByAppendingPathComponent:[[FUHandle handle] getFWName]];
    [BKUtils deleteFileByPath:firmwareURL];
}

- (void)updateUIAferComplete {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_udView updateProgress:1 color:[UIColor colorFromCode:0xFFFFFF inAlpha:1]];
        [self updateUIState:[self getStateParams:@"升级成功" andDFUState:DFUState_Return]];
    });
}

- (void)updateUISaveInfo {
    [self updateUIState:[self getStateParams:@"正在保存信息..." andDFUState:DFUState_Waiting]];
}

- (void)updateUIWaiting {
    [self updateUIState:[self getStateParams:@"请等待" andDFUState:DFUState_Waiting]];
}

- (void)updateUINoNeed {
    
    [_udView updateProgress:1 color:[UIColor colorFromCode:0xFFFFFF inAlpha:1.0]];
    [self updateUIState:[self getStateParams:@"最新版本，无需升级" andDFUState:DFUState_Return]];
}

- (void)updateUIUnKnowError {
    
    [_udView updateProgress:0 color:[UIColor colorFromCode:0xFFFFFF inAlpha:1.0]];
    [self updateUIState:[self getStateParams:@"未知错误，请返回" andDFUState:DFUState_Return]];
}

- (void)updateUIFail {
    
    [_udView updateProgress:0.0 color:[UIColor colorFromCode:0xFFFFFF inAlpha:1.0]];
    [self updateUIState:[self getStateParams:@"升级失败" andDFUState:DFUState_Retry]];
}

- (void)updateUIReady {
    [self updateUIState:[self getStateParams:@"保存信息成功" andDFUState:DFUState_Waiting]];
}

- (void)updateUIPercent:(NSInteger)percentage {
    
    if (percentage>=100) {
        percentage = 99;
    }
    NSInteger timeSecond = [self timeNeed];
    NSString *timeText ;
    NSInteger time = timeSecond *(1-percentage/100.0);

    if (time>60) {
        timeText = [NSString stringWithFormat:@"剩余 %i 分钟", (int)time/60];
    }else{
        timeText = [NSString stringWithFormat:@"剩余 %i 秒", (int)time];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_udStateLab setText:@"更新中"];
        [self->_udProgressLab setText:[NSString stringWithFormat:@"[ %li%% ]", (long)percentage+1]]; 
        [self->_udTimeNoticeLab setText:timeText];
        [self->_udView updateProgress:((percentage+1)/100.0) color:[UIColor colorFromCode:0xFFFFFF inAlpha:1]];
    });
}

- (void)updateUIDownload{
    [self updateUIState:[self getStateParams:@"固件下载中..." andDFUState:DFUState_Waiting]];
}

- (void)updateUIDownloadFail{
    [self updateUIState:[self getStateParams:@"固件下载失败..." andDFUState:DFUState_DownLoadFial]];
}

- (void)updateUIDownloadSuccessful {
    [self updateUIState:[self getStateParams:@"固件下载完成" andDFUState:DFUState_Waiting]];
}

- (void)updateUINoData {
    
    [_bgTipLab setText:@"没有设备可以升级"];
    [self drawBottomBtn];
    self.state = DFUState_Return;
    [self setUdbtnTitle:@"返回"];
}

- (void)updateCheckDFU {
    
    [_bgTipLab setText:@"升级助手"];
    [self drawBottomBtn];
    [self setUdbtnTitle:@"开始"];
}

#pragma mark- 公共Method   校验／保存信息(下载信息)/下载固件
- (void)requestForCheckDFU {
    
    if (_fwContent) {
        self.state = DFUState_Start;
        [self prepareUpgradeView];
    }else {
        [self prepareNoUpdateView];
    }
}

- (void)downloadFirmware:(void(^)(void))downloadFWSuccessful {
    
    NSLog(@"%s",__func__);
    NSString *fwURL = _fwUrl;
    if (!fwURL) {
        [self performSelectorOnMainThread:@selector(updateUIUnKnowError) withObject:nil waitUntilDone:YES];
        return;
    }
    [self updateUIDownload];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        if (![[FUHandle handle] downFWFromURL:fwURL]) {
            [self performSelectorOnMainThread:@selector(updateUIDownloadFail) withObject:nil waitUntilDone:YES];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUIDownloadSuccessful];
            downloadFWSuccessful();
        });
    });
}

- (void)udBtnClicked:(id)sender {
    
    if (self.state == DFUState_Start) {
        [self prepareDFUUpgrade];

    } else if (self.state == DFUState_Return){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)returnBtnClicked:(id)sender {
    
    if (self.state == DFUState_Waiting) {
        [self showBackAlter];
    }else {
        [self finishUpgradeUI];
        _gifView = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showBackAlter {
    
    DFUAlertView *alert = [DFUAlertView createInView:self.view];
    alert.titleLabel.text = @"温馨提示";
    alert.detailLabel.text = @"升级过程中请勿退出，否则升级可能会失败";
    
    __weak typeof(self) weakself = self;
    __weak typeof(DFUAlertView) *weakalert = alert;
    
    [alert setLeftTitle:@"继续升级" leftAction:^{
        [weakalert hideWithAnimate:NO];
    } andRightTitle:@"仍然退出" rightAction:^{
        [weakalert hideWithAnimate:YES];
        [weakself signOffDelegate];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert show];
}

#pragma mark- observer
- (void)applicationDidEnterBackground {
    [_gifView stop];
}

- (void)applicationWillEnterForeground {
    [_gifView play];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark -function
- (void)toastDisplay:(id)string {
    [Toast makeToast:(NSString *)string duration:6.0 position:CSToastPositionBottom];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)timeNeed {
    if (_timeNeed == 0) {
        _timeNeed = [self timeIntervalOfFwUpgrade];
    }
    return _timeNeed;
}

- (NSInteger)timeIntervalOfFwUpgrade {
    
    NSString *fullPath = [[FUHandle handle] getFWPath];
    unsigned long long sizeOfFile = [[[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil] fileSize];
    if ([fullPath hasSuffix:@".hex"]) {
        return (NSInteger)sizeOfFile/5437; //hex
    }else{
        return (NSInteger)sizeOfFile/1127; //zip
    }
}
@end
