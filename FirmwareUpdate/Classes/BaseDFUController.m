//
//  BaseDFUController.m
//  ZLYIwown
//
//  Created by caike on 16/8/31.
//  Copyright © 2016年 Iwown. All rights reserved.
//
#import "IVNetHeader.h"
#import "Toast.h"
#import "FUHandle.h"
#import <MBProgressHUD.h>
#import "BaseDFUController.h"
#import <IVBaseKit/IVBaseKit.h>
#import "DFUAlertView.h"
#import "DFUOverView.h"

@interface BaseDFUController ()
{
    UpdateCircle        *_udView;
    
    UIView              *_menuView;
    
    UILabel             *_udStateLab;
    UILabel             *_udProgressLab;
    UILabel             *_udTimeNoticeLab;
    UILabel             *_udTipLab;
    UILabel             *_bgTipLab;
    
    NSInteger           _timeNeed;
    
}
@end

@implementation BaseDFUController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[FUHandle shareInstance].delegate respondsToSelector:@selector(fuHandleActionBegin)]) {
        [[FUHandle shareInstance].delegate fuHandleActionBegin];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    if ([[FUHandle shareInstance].delegate respondsToSelector:@selector(fuHandleActionEnd)]) {
        [[FUHandle shareInstance].delegate fuHandleActionEnd];
    }
}

- (NSString *)upgradeTime {
    NSString *model = _fwModel;
    if ([model hasPrefix:@"I5"]) {
        return @"2～5分钟";
    }else if ([model hasPrefix:@"I6"]) {
        return @"5～10分钟";
    }else if ([model hasPrefix:@"I7"]) {
        return @"5～15分钟";
    }else if ([model hasPrefix:@"V6"]) {
        return @"3～10分钟";
    }else {
        return @"5～15分钟";
    }
}

- (void)signOffDelegate {}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initParam];
    [self initUI];
}

- (void)initParam {}

#pragma mark UI
static int DFU_BG_VIEW_TAG = 10000;
- (void)initUI {
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self drawBackGroundView];
    _menuView = [UIView drawMenuBarTitle:NSLocalizedString(@"手环升级", @"手环升级")
                                       delegate:self
                                       leftIcon:@"back"
                                       leftText:NSLocalizedString(@"返回", nil)
                                     leftAction:@selector(returnBtnClicked:)
                                      rightIcon:nil
                                      rightText:nil
                                    rightAction:nil
                                     andBgStyle:IVNavigationBarStyleNone];
    _menuView.backgroundColor = [NavigationBarColor colorWithAlphaComponent:0];
    [[self view] bringSubviewToFront:_menuView];
}

- (void)drawBackGroundView {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hardware_bg.jpg"]];
    [imgView setFrame:self.view.bounds];
    [imgView setTag:DFU_BG_VIEW_TAG];
    _bgTipLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0.12, SCREEN_HEIGHT*0.47, SCREEN_WIDTH*(1-0.24), FONT(40))];
    [_bgTipLab setTextAlignment:NSTextAlignmentCenter];
    [_bgTipLab setTextColor:[UIColor colorFromCode:0xffffff inAlpha:1]];
    [imgView addSubview:_bgTipLab];
    [[self view] addSubview:imgView];
}

- (void)drawUpdateInfoView {
    UIView *bgView = [self.view viewWithTag:DFU_BG_VIEW_TAG];
    [_bgTipLab setNumberOfLines:2];
    [_bgTipLab setText:[NSString stringWithFormat:@"本次升级预计%@,\n升级过程中请保持在升级页面，不要退出",[self upgradeTime]]];
    [_bgTipLab setFont:[UIFont systemFontOfSize:FONT(13)]];

    UILabel *labV = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0.145, SCREEN_HEIGHT*0.60, SCREEN_WIDTH*(1-0.29), FONT(20))];
    [labV setTextColor:[UIColor colorFromCode:0xffffff inAlpha:1]];
    [labV setFont:[UIFont systemFontOfSize:FONT(13)]];
    [labV setText:[NSString stringWithFormat:@"版本号：%@",self.fwContent[@"fw_version"]]];

    UILabel *labInfoA = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0.145, SCREEN_HEIGHT*0.60+FONT(35), SCREEN_WIDTH*(1-0.29), FONT(20))];
    [labInfoA setTextColor:[UIColor colorFromCode:0xffffff inAlpha:1]];
    [labInfoA setFont:[UIFont systemFontOfSize:FONT(13)]];
    [labInfoA setText:NSLocalizedString(@"版本更新内容：", nil)];
    
    UILabel *labInfoB = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0.145, SCREEN_HEIGHT*0.60+FONT(55), SCREEN_WIDTH*(1-0.29), FONT(40))];
    [labInfoB setTextColor:[UIColor colorFromCode:0xffffff inAlpha:0.7]];
    [labInfoB setFont:[UIFont systemFontOfSize:FONT(12)]];
    [labInfoB setNumberOfLines:0];
    [labInfoB setText:[NSString stringWithFormat:@"%@",self.fwContent[@"update_information"]]];
    [labInfoB sizeToFit];
    
    [bgView addSubview:labV];
    [bgView addSubview:labInfoA];
    [bgView addSubview:labInfoB];
}

- (void)drawGtadientBGView {

   /* GradientView *gView = [[GradientView alloc] initWithFrame:CGRectMake(0,0 ,SCREEN_WIDTH,SCREEN_HEIGHT) andGradientDirection:GradientDirectionFromTop andBeginColorRGBA:(CGFloat[]){3/255.0, 166/255.0, 141/255.0, 1} andEndColorRGBA: (CGFloat[]){71/255.0, 202/255.0, 169/255.0, 1}];*/
    UIView *gView = [[UIView alloc] initWithFrame:CGRectMake(0,0 ,SCREEN_WIDTH,SCREEN_HEIGHT)];
    [gView setBackgroundColor:[UIColor colorFromCode:[FUHandle shareInstance].fuNBCI inAlpha:1]];
    [self.view addSubview:gView];
    [self.view sendSubviewToBack:gView];
}

- (void)drawUpdateCircle {
    
    _udView = [[UpdateCircle alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*0.138, SCREEN_WIDTH, SCREEN_HEIGHT*0.45) baseColor:[UIColor whiteColor] coverColor:[UIColor whiteColor] withPercent:0];
    [[self view] addSubview:_udView];
}

- (void)drawBottomBtn {
    if (_udBtn) {
        return;
    }
    _udBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_udBtn setFrame:CGRectMake(0.5*(SCREEN_WIDTH-FONT(80)), SCREEN_HEIGHT-FONT(90), FONT(80), FONT(36))];
    [_udBtn addTarget:self action:@selector(udBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_udBtn setTitleColor:[UIColor colorFromCode:0xffffff inAlpha:1.0] forState:UIControlStateNormal];
    [_udBtn setTitleColor:[UIColor colorFromCode:0xDADADA inAlpha:1.0] forState:UIControlStateHighlighted];
    [_udBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[_udBtn titleLabel] setFont:[UIFont boldSystemFontOfSize:(20.0/414.0*SCREEN_WIDTH)]];
    [[_udBtn layer] setMasksToBounds:YES];
    [[_udBtn layer] setCornerRadius:FONT(18.0)];
    [[_udBtn layer] setBorderWidth:1];
    [[_udBtn layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[_udBtn titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [[self view] addSubview:_udBtn];
    [[self view] bringSubviewToFront:_udBtn];
}

- (void)drawStateInfoView {
    _udStateLab = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*0.588, SCREEN_WIDTH, FONT(25))];
    [_udStateLab setText:@"升级准备中..."];
    [_udStateLab setTextAlignment:NSTextAlignmentCenter];
    [_udStateLab setTextColor:[UIColor whiteColor]];
    [_udStateLab setFont:[UIFont systemFontOfSize:FONT(14)]];
    
    _udProgressLab = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*0.588 +FONT(30), SCREEN_WIDTH, FONT(30))];
    [_udProgressLab setText:@"[ 0% ]"];
    [_udProgressLab setTextAlignment:NSTextAlignmentCenter];
    [_udProgressLab setTextColor:[UIColor whiteColor]];
    [_udProgressLab setFont:[UIFont systemFontOfSize:FONT(20)]];
    
    _udTimeNoticeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*0.588 +FONT(65), SCREEN_WIDTH, FONT(25))];
    [_udTimeNoticeLab setText:@"剩余约0分钟"];
    [_udTimeNoticeLab setTextAlignment:NSTextAlignmentCenter];
    [_udTimeNoticeLab setTextColor:[UIColor whiteColor]];
    [_udTimeNoticeLab setFont:[UIFont systemFontOfSize:FONT(14)]];

    [[self view] addSubview:_udStateLab];
    [[self view] addSubview:_udProgressLab];
    [[self view] addSubview:_udTimeNoticeLab];
}

- (void)drawTipsView {
    
    _udTipLab = [[UILabel alloc] initWithFrame:CGRectMake(FONT(30), SCREEN_HEIGHT*0.83, SCREEN_WIDTH-FONT(60), 60)];
    [_udTipLab setText:NSLocalizedString(@"升级过程中请注意:\n1、升级中请勿让手环远离手机 \n2、升级中请勿退出升级页面，避免升级失败导致手环不可用",nil)];
    [_udTipLab setFont:[UIFont systemFontOfSize:19]];
    [_udTipLab setTextColor:[UIColor whiteColor]];
    [_udTipLab setBackgroundColor:[UIColor clearColor]];
    [_udTipLab setTextAlignment:NSTextAlignmentLeft];
    [_udTipLab setNumberOfLines:0];
    [_udTipLab setAdjustsFontSizeToFitWidth:YES];
    
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT - 30, SCREEN_WIDTH-40, 30)];
    [tipLabel setText:NSLocalizedString(@"PS:手环升级时请确保设备电量不低于50%",nil)];
    [tipLabel setFont:[UIFont boldSystemFontOfSize:FONT(14)]];
    [tipLabel setTextColor:[UIColor colorFromCode:0xABABAB inAlpha:1.0]];
    [tipLabel setBackgroundColor:[UIColor clearColor]];
    [tipLabel setTextAlignment:NSTextAlignmentLeft];
    [tipLabel setAdjustsFontSizeToFitWidth:YES];
    [tipLabel setTag:tips_tag];
    
    [[self view] addSubview:_udTipLab];
    [[self view] addSubview:tipLabel];
}

static int tips_tag = 9342;
- (void)updateTipsContent:(NSString *)tips {
    UILabel *tipsLab = [(UILabel *)[self view] viewWithTag:tips_tag];
    [tipsLab setText:tips];
}

- (void)tapAction:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)alertForDFU {
    UIView *coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:coverView];
    coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    coverView.tag = COVER_VIEW_TAG;
    
    CGFloat width = SCREEN_WIDTH*0.74;
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_bg"]];
    [bg setFrame:CGRectMake(0.5*(SCREEN_WIDTH-width), 0.34*SCREEN_HEIGHT, width, SCREEN_HEIGHT*0.28)];
    [bg setUserInteractionEnabled:YES];
    [coverView addSubview:bg];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*0.06,width, FONT(40))];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor colorFromCode:0x2ec990 inAlpha:1]];
    [lab setText:@"确认是否升级"];
    [bg addSubview:lab];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0.14*width, SCREEN_HEIGHT *0.135, width*0.3, FONT(30));
    [leftButton setTitle:@"是" forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorFromCode:0x2ec990 inAlpha:1]] forState:UIControlStateHighlighted];
    [leftButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorFromCode:0xFFFFFF inAlpha:1]] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorFromCode:0x2ec990 inAlpha:1] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorFromCode:0xFFFFFF inAlpha:1] forState:UIControlStateHighlighted];
    [leftButton.layer setCornerRadius:FONT(15)];
    [leftButton.layer setMasksToBounds:YES];
    [leftButton.layer setBorderColor:[UIColor colorFromCode:0x2ec990 inAlpha:1].CGColor];
    [leftButton.layer setBorderWidth:1];
    [leftButton addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:leftButton];
    
    UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0.56*width, SCREEN_HEIGHT *0.135, width*0.3, FONT(30));
    [rightButton setTitle:@"否" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorFromCode:0x2ec990 inAlpha:1] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorFromCode:0xFFFFFF inAlpha:1] forState:UIControlStateHighlighted];
    [rightButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorFromCode:0x2ec990 inAlpha:1]] forState:UIControlStateHighlighted];
    [rightButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorFromCode:0xFFFFFF inAlpha:1]] forState:UIControlStateNormal];
    [rightButton.layer setCornerRadius:FONT(15)];
    [rightButton.layer setMasksToBounds:YES];
    [rightButton.layer setBorderColor:[UIColor colorFromCode:0x2ec990 inAlpha:1].CGColor];
    [rightButton.layer setBorderWidth:1];
    [rightButton addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:rightButton];
}

static int COVER_VIEW_TAG = 20000;
- (void)leftAction:(id)sender {
    [self rightAction:sender];
    [self prepareDFUUpgrade];
}

- (void)rightAction:(id)sender {
    [[self.view viewWithTag:COVER_VIEW_TAG] removeFromSuperview];
}

- (void)prepareUpgradeView {
    [self drawUpdateInfoView];
    [self drawBottomBtn];
    [self setUdbtnTitle:@"开始升级"];
}

- (void)prepareNoUpdateView {
    [_bgTipLab setText:@"已是最新版本，无需升级"];
    self.state = DFUState_Return;
    [self drawBottomBtn];
    [self setUdbtnTitle:@"点击返回"];
}

- (void)entryUpgradeView {
    
    [self drawGtadientBGView];
    UIView *bgView = [self.view viewWithTag:DFU_BG_VIEW_TAG];
    [UIView animateWithDuration:1.0 animations:^{
        bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [bgView removeFromSuperview];
        [self drawUpdateCircle];
        [self drawStateInfoView];
        [self drawTipsView];
        [self setUdbtnTitle:nil];
        [_udView startAnimation];
    }];
}

- (void)prepareDFUUpgrade {
    [self entryUpgradeView];  //刷新界面
}

#pragma mark 更新UI状态

- (void)removeCompleteView {
    [[self.view viewWithTag:white_tag] removeFromSuperview];
}

static int white_tag = 1029;
- (void)newCompleteAnimationView {
    
    typeof(self) __safe_self = self;
    DFUOverView * overView = [[DFUOverView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NavigationBarHeight) andSELLeft:^{
        [__safe_self completeBtnClickLeft];
    } andSELRight:^{
        [__safe_self completeBtnClickRight];
    }];
    overView.tag = white_tag;
    [self.view addSubview:overView];
    [UIView animateWithDuration:0.6 animations:^{
        [overView setFrame:CGRectMake(0, NavigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-NavigationBarHeight)];
    }];
}
- (void)completeBtnClickLeft {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)completeBtnClickRight {
    [self removeCompleteView];
    [self setUdbtnTitle:nil];
    self.state = DFUState_Retry;
    [self udBtnClicked:nil];
}

- (void)setUdbtnTitle:(NSString *)title {
    if (title == nil) {
        [_udBtn setHidden:YES];
        [_udTipLab setHidden:NO];
        [_udBtn setTitle:@"" forState:UIControlStateNormal];
    }else{
        [_udBtn setHidden:NO];
        [_udTipLab setHidden:YES];
        [_udBtn setTitle:title forState:UIControlStateNormal];
    }
}

- (id)getStateParams:(NSString *)text
         andDFUState:(DFUState)state {
    return @{@"text":text,@"state":@(state)};
}

- (void)updateUIState:(id)stateInfo {
    
    NSString *text = (NSString *)stateInfo[@"text"];
    DFUState state = (DFUState)[stateInfo[@"state"] integerValue];
    [_udStateLab setText:text];
    
    self.state = state;
    switch (state) {
        case DFUState_Null:
        {
            self.state = DFUState_Retry;
            [self setUdbtnTitle:NSLocalizedString(@"重试", @"重试")];
        }
            break;
        case DFUState_Return:
            [self setUdbtnTitle:NSLocalizedString(@"返回", @"返回")];
            break;
        case DFUState_Retry:
            [self setUdbtnTitle:NSLocalizedString(@"重试", @"重试")];
            break;
        case DFUState_DownLoadFial:
            [self setUdbtnTitle:NSLocalizedString(@"下载", @"下载")];
            break;
        case DFUState_Waiting:
            [self setUdbtnTitle:nil];
            break;
        case DFUState_Helper:
            [self setUdbtnTitle:NSLocalizedString(@"升级助手", nil)];
            break;
        case DFUState_SaveInfo:
            [self setUdbtnTitle:NSLocalizedString(@"重试", @"保存信息")];
            break;
        case DFUState_Start:
            [self setUdbtnTitle:NSLocalizedString(@"开始升级", @"开始升级")];
            break;
            
        default:
            break;
    }
}

- (void)finallySuccessful {
    [self updateUIAferComplete];
    [self newCompleteAnimationView];
    NSString *filePath = [[FUHandle shareInstance] getFWPathFromModel:_fwModel];
    [self deleteFWWithPath:filePath];
}

- (void)updateUIAferComplete {
    [_udView updateProgress:1 color:[UIColor whiteColor]];
    [self updateUIState:[self getStateParams:NSLocalizedString(@"升级完成",@"Upgrade Complete") andDFUState:DFUState_Return]];
    _menuView.backgroundColor = [NavigationBarColor colorWithAlphaComponent:1];
}

- (void)updateUISaveInfo {
    [self updateUIState:[self getStateParams:NSLocalizedString(@"正在保存信息...",nil) andDFUState:DFUState_Waiting]];
}

- (void)updateUIWaiting
{
    [self updateUIState:[self getStateParams:NSLocalizedString(@"等待...",nil) andDFUState:DFUState_Waiting]];
}

- (void)updateUINoNeed
{
    [_udView updateProgress:1 color:[UIColor whiteColor]];
    [self updateUIState:[self getStateParams:NSLocalizedString(@"已经是最新版本",nil) andDFUState:DFUState_Return]];
}

- (void)updateUIUnKnowError{
    [_udView updateProgress:0 color:[UIColor whiteColor]];
    [self updateUIState:[self getStateParams:NSLocalizedString(@"升级参数缺失，请返回",@"升级参数缺失，请返回") andDFUState:DFUState_Return]];
}

- (void)updateUIFail
{
    [_udView updateProgress:0.0 color:[UIColor whiteColor]];
    [self updateUIState:[self getStateParams:NSLocalizedString(@"升级失败，请重试！",nil) andDFUState:DFUState_Retry]];
}

- (void)updateUIReady {
    [self updateUIState:[self getStateParams:NSLocalizedString(@"保存信息成功",nil) andDFUState:DFUState_Waiting]];
}

- (void)updateUIPercent:(NSInteger)percentage {
    if (percentage>=100) {
        percentage = 99;
    }
    NSInteger timeSecond = [self timeNeed];
    NSString *timeText ;
    NSInteger time = timeSecond *(1-percentage/100.0);

    if (time>60) {
        timeText = [NSString stringWithFormat:@"剩余约%i分钟", (int)time/60];
    }else{
        timeText = [NSString stringWithFormat:@"剩余约%i秒", (int)time];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_udStateLab setText:NSLocalizedString(@"升级中，请耐心等待",nil)];
        [_udProgressLab setText:[NSString stringWithFormat:@"[ %li%% ]", (long)percentage+1]];
        [_udTimeNoticeLab setText:timeText];
        [_udView updateProgress:((percentage+1)/100.0) color:[UIColor whiteColor]];
    });
}

- (void)updateUIDownload{
    [self updateUIState:[self getStateParams:NSLocalizedString(@"固件下载中，请勿返回...",nil) andDFUState:DFUState_Waiting]];
}

- (void)updateUIDownloadFail{
    [self updateUIState:[self getStateParams:NSLocalizedString(@"下载固件失败，请联系客服！",nil) andDFUState:DFUState_DownLoadFial]];
}

- (void)updateUIDownloadSuccessful {
    [self updateUIState:[self getStateParams:NSLocalizedString(@"下载固件完成，即将开始升级",nil) andDFUState:DFUState_Waiting]];
}

- (void)updateUINoData {
    
    [_bgTipLab setText:NSLocalizedString(@"无可用升级工具，请返回",nil)];
    [self drawBottomBtn];
    self.state = DFUState_Return;
    [self setUdbtnTitle:@"点击返回"];
}

- (void)updateCheckDFU
{
    [_bgTipLab setText:NSLocalizedString(@"手环升级助手",nil)];
    [self drawBottomBtn];
    [self setUdbtnTitle:@"开始升级"];
    [self updateTipsContent:NSLocalizedString(@"PS:长时间处于等待状态请返回重试", nil)];
}

#pragma mark 公共Method   校验／保存信息(下载信息)/下载固件
- (void)requestForCheckDFU:(DFUDevice)device {
    
    //校验所需参数
    ZeronerDeviceInfo *_dInfo = nil;
    if (device == DFUDevice_Bracelet) {
        _dInfo = [FUHandle shareInstance].deviceInfo;
    }else {
        return;
    }
    NSDictionary *parapms = [self getDFUParamsAtPlatform:_dInfo];

    //UI
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.detailsLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.view addSubview:HUD];
    [HUD showAnimated:YES];
    HUD.removeFromSuperViewOnHide = YES;
    
    IVHttpRequest *request = [IVHttpRequest requestWithService:SERVICE_DEVICE api:API_FW_UPDATE parameters:parapms];
    [IVHttpClient sendAsyncPostRequest:request completion:^(id responseObj, NSError *error) {
        [HUD hideAnimated:NO];
        if (error) {
            [self updateUIState:[self getStateParams:NSLocalizedString(@"系统繁忙，请稍后重试", nil) andDFUState:DFUState_Retry]];
            return;
        }
        NSDictionary *fwInfo = responseObj[@"firmware"];
        if (fwInfo) {
            NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:fwInfo];
            [mDict setObject:_dInfo.bleAddr forKey:@"mac_address"];
            [mDict setObject:_dInfo.model forKey:@"model"];
            _fwContent = mDict;//缓存升级信息
            self.state = DFUState_Start;
            [self prepareUpgradeView];
        }
        else {
            [self prepareNoUpdateView];
        }
    }];
}

- (void)downloadFirmware:(void(^)())downloadFWSuccessful {
    
    NSString *model = _fwModel;
    NSString *fwURL = _fwUrl;
    if (!model && !fwURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(updateUIUnKnowError) withObject:nil afterDelay:1.2];
        });
        return;
    }
    [self updateUIDownload];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        if (![self downFWFromURL:fwURL andFilePath:[[FUHandle shareInstance] getFWPathFromModel:model]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(updateUIDownloadFail) withObject:nil afterDelay:1.2];
            });
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
        [self alertForDFU];
    }else if (self.state == DFUState_Return) {
        [[BLELib3 shareInstance] registerDeviceDelegate];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)returnBtnClicked:(id)sender
{
    if (self.state == DFUState_Waiting) {
        DFUAlertView *alert = [DFUAlertView createInView:self.view];
        alert.titleLabel.text = NSLocalizedString(@"温馨提示", @"温馨提示");
        alert.detailLabel.text =NSLocalizedString(@"升级过程中退出会导致升级失败，手环将会无法使用", @"升级过程中退出会导致升级失败，手环将会无法使用");
        
        __weak typeof(self) weakself = self;
        __weak typeof(DFUAlertView) *weakalert = alert;
        
        [alert setLeftTitle:NSLocalizedString(@"离开",@"离开") leftAction:^{
            [weakalert hideWithAnimate:NO];
            [weakself signOffDelegate];
            [weakself dismissViewControllerAnimated:YES completion:nil];
            
        } andRightTitle:NSLocalizedString(@"继续升级", @"继续升级") rightAction:^{
            [weakalert hideWithAnimate:YES];
        }];
        [alert show];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark -function
- (void)toastDisplay:(id)string
{
    [Toast makeToast:(NSString *)string duration:6.0 position:CSToastPositionBottom];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)timeNeed {
    if (_timeNeed == 0) {
        _timeNeed = [self timeIntervalOfFwUpgrade];
    }
    return _timeNeed;
}

- (NSInteger)timeIntervalOfFwUpgrade {
    
    NSString *model = _fwModel;
    if (!model) {
        return 0;
    }
    NSString *fullPath = [[FUHandle shareInstance] getFWPathFromModel:model];
    unsigned long long sizeOfFile = [[[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil] fileSize];
    if ([model hasPrefix:@"i5+"]) {
        return (NSInteger)sizeOfFile/5437; //hex
    }else{
        return (NSInteger)sizeOfFile/1127; //zip
    }
}

#pragma mark -fwDownload
- (BOOL)dfuFileIsExist:(NSString *)model {
    
    if (!model) {
        return NO;
    }
    
    NSString *fullPath = [[FUHandle shareInstance] getFWPathFromModel:model];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:fullPath]) {
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)downFWFromURL:(NSString *)fileURL andFilePath:(NSString *)filePath {
    NSLog(@"执行固件下载函数:%@,%@",fileURL,filePath);
    [self deleteFWWithPath:filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL] options:NSDataReadingMappedIfSafe error:&error];
        NSLog(@"%@",error);
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
        [fileManager createFileAtPath:filePath contents:data attributes:nil];
        
        if ([[fileManager contentsAtPath:filePath] length] == 0) {
            NSLog(@"固件下载失败");
            return NO;
        }
        else
        {
            NSLog(@"固件下载完成");
            return YES;
        }
    }
    else
    {
        NSLog(@"固件已存在");
        return YES;
    }
}

- (BOOL)deleteFWWithPath:(NSString *)filePath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    __autoreleasing NSError *err;
    if ([fileManager fileExistsAtPath:filePath])
    {
        return [fileManager removeItemAtPath:filePath error:&err];
    }
    return YES;
}

- (NSDictionary *)getDFUParamsAtPlatform:(ZeronerDeviceInfo *)dInfo
{
    NSNumber *platform = [[FUHandle shareInstance] devicePlatformNumber];
    NSNumber *modelNum = [[FUHandle shareInstance] deviceModelNumber];
    NSNumber *appNumber = [[FUHandle shareInstance].delegate fuHandleParamsAppName];
    NSString *appVStr= [[FUHandle shareInstance].delegate fuHandleParamsBuildVersion];
    NSNumber *appVersion = NSNumberWithStringUid(appVStr);
    NSNumber *appPlatform = @2;//1. android 2. iOS  8. all
    NSNumber *deviceType = [[FUHandle shareInstance] deviceTypeNumber];
    NSNumber *module = @1; //1->application , bootload ,心率
    NSNumber *skip = @0; // 0->通用模式，1->无限升级 ，2->关闭升级
#ifdef DEVELOPER_TEST
    skip = @1;
#endif

    NSDictionary *urlParams = @{@"platform":platform,
                                @"device_type":deviceType,
                                @"device_model":modelNum,
                                @"fw_version":dInfo.version,
                                @"app":appNumber,
                                @"app_version":appVersion,
                                @"app_platform":appPlatform,
                                @"module":module,
                                @"skip":skip};
    NSLog(@"%@",urlParams);
    return urlParams;
}

//删除Bootloader
- (BOOL)deleteBootloader {
    NSString *firmwareName = @"bootloader.hex";
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:firmwareName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    __autoreleasing NSError *err;
    if ([fileManager fileExistsAtPath:fullPath])
    {
        return [fileManager removeItemAtPath:fullPath error:&err];
    }
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
